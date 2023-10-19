import Deferred from "./deferred";
import Awaiter from "./awaiter";



// SalesforceのSObjectを保存したときにトリムされるホワイトスペース
const SF_WHITESPACE = "[\\x00-\\x20\\u1680\\u180E\\u2000-\\u2006\\u2008-\\u200A\\u2028\\u2029\\u205F\\u3000]";

// 先頭に連続するホワイトスペース
const LEADING_WHITESPACE_REGEX = new RegExp(`^${SF_WHITESPACE}+`);

// 末尾に連続するホワイトスペース
const TRAILING_WHITESPACE_REGEX = new RegExp(`${SF_WHITESPACE}+$`);

// ホワイトスペースの繰り返し
const REPEATING_WHITESPACE_REGEX = new RegExp(`${SF_WHITESPACE}+`);

// ブランク文字列の正規表現
const BLANK_REGEX = new RegExp(`^${SF_WHITESPACE}*$`);

// HTML特殊文字エスケープ辞書
const HTML_SPECIAL_CHARS = {
    "<": "&lt;",
    ">": "&gt;",
    "&": "&amp;",
    '"': "&quot;"
};

/**
 * 正規表現特殊文字のエスケープ。
 * 参考: https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Regular_Expressions#escaping
 * @param x 文字列
 * @returns {string} xに含まれる正規表現特殊文字をエスケープした文字列
 */
function escapeRegEx(x) {
    return x.replace(/[.*+?^=!:${}()|[\]/\\]/g, "\\$&");
}

/**
 * HTML特殊文字のエスケープ。
 * <, >, &, " を実体参照に置き換える。
 * @param x 文字列
 * @returns {string} xに含まれるHTML特殊文字をエスケープした文字列
 */
function escapeHtml(x) {
    return x.replace(/[<>&"]/g, (match) => HTML_SPECIAL_CHARS[match]);
}

/**
 * SObject保存時と同等のトリム（前後のホワイトスペース除去）。
 * @param x 文字列
 * @returns {string} xの前後のホワイトスペースを除去した文字列。xがnull or undefinedのときは空文字列。
 */
function trim(x) {
    return x == null ? "" : x.replace(LEADING_WHITESPACE_REGEX, "").replace(TRAILING_WHITESPACE_REGEX, "");
}

/**
 * 文字列のブランク判定。ブランクとはSObjectに保存したときnullになることを指す。
 * @param x 文字列
 * @returns {string} xがSObjectに保存したときnullになる文字列、null, undefinedの場合true
 */
function isBlank(x) {
    if (x == null) {
        return true;
    }
    if (typeof x !== 'string' && !(x instanceof String)) {
        return false;
    }
    return x.match(BLANK_REGEX);
}

/**
 * ホワイトスペースで分割。ホワイトスペースとはSObjectに保存したときトリムされる文字を指す。
 * @param x 文字列。前後のホワイトスペースは除去する。
 * @returns {Array<string>} xを連続するホワイトスペースで分割した文字列配列。xがnull, 空文字列、ホワイトスペースのみの文字列の場合は空配列。
 */
function splitByBlank(x) {
    x = trim(x);
    return x ? x.split(REPEATING_WHITESPACE_REGEX) : [];
}

/**
 * オブジェクトの、パスで指定したプロパティを返す。プロパティはドット記法で「深く」辿れる。
 * 例えば、<code>dig(object, 'a.c.0.c')</code>は<code>object.a.b[0].c</code>と同等。
 * 途中でnull or undefinedが出現した場合はそこで探索を打ち切る。
 * @param object オブジェクト。null or undefinedでもよい。
 * @param path 探索するパス。ドット記法か、文字列・数値の配列。
 * @returns {*} オブジェクトの、パスで指定したプロパティ。
 */
function dig(object, path) {
    if (!Array.isArray(path)) {
        path = path.split(".");
    }
    for (let e of path) {
        if (object == null) {
            return object;
        }
        object = object[e];
    }
    return object;
}

/**
 * 配列に出現する、最初のnullでもundefinedでもない要素を返す。
 * @param xs 配列
 * @returns {*|undefined} 最初のnullでもundefinedでもない要素。なければundefined。配列がnull or undefinedならundefined
 */
function coalesce(xs) {
    return xs == null ? undefined : xs.find((e) => e != null);
}

/**
 * 指定したミリ秒待つ。setTimeoutのPromise
 * @param ms ミリ秒
 * @returns {Promise}
 */
function wait(ms = 0) {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * 指定したミリ秒待ってから関数fnを実行する関数を返す。
 * fn実行前に何度も呼び出した場合、最後の呼び出しから待つ。
 * @param fn 実行する関数
 * @param ms ミリ秒
 * @returns {Function} ミリ秒待ってから関数fnを実行する関数。cancelプロパティに、実行待ちをキャンセルする関数が設定される。
 */
function debounce(fn, ms) {
    let timerId;

    const debounced = function (...args) {
        clearTimeout(timerId);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        timerId = setTimeout(() => {
            fn(...args);
        }, ms);
    };
    debounced.cancel = function () {
        clearTimeout(timerId);
    };

    return debounced;
}

/**
 * 15桁IDを18桁IDにする。
 * @param id 15桁ID
 * @returns {string} 18桁ID。idが15桁IDでない場合はidをそのまま帰す
 */
function caseSafeId(id) {
    if (!id || id.length !== 15 || id.match(/[\W_]/)) {
        return id;
    }
    const suffix = [0, 5, 10]
        .map((n) => id.substring(n, n + 5))
        .map((chunk) => chunk.replace(/[a-z\d]/g, "0").replace(/[A-Z]/g, "1"))
        .map((e) => Array.from(e).reverse().join(""))
        .map((e) => "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(parseInt(e, 2)))
        .join("");
    return id + suffix;
}

/**
 * 引数がnullかundefinedなら空配列、配列ならそのまま、配列でなければ配列でラップして返す
 * @param considerArray
 * @returns {Array} 配列
 */
function wrapArray(considerArray) {
    if (Array.isArray(considerArray)) {
        return considerArray;
    }
    return considerArray == null ? [] : [considerArray];
}

/**
 * JSON.parseしてエラーならnullを返す
 * @param str JSON文字列
 * @returns {*} パースした結果。パースエラーならnull
 */
function parseJsonSafe(str) {
    try {
        return JSON.parse(str);
    } catch (ex) {
        return null;
    }
}

/**
 * 文字列のフォーマット。
 * ApexのString.formatみたいなメソッド。ただし引用符はサポートしない。
 * 例えば、<code>formatMessage('{0} is {1}', ['This', 'a pen'])</code>は<code>"This is a pen"</code>となる。
 * @param format フォーマット
 * @param params バインド変数の配列
 * @returns {string} フォーマットされた文字列
 */
function formatMessage(format, params) {
    if (format == null || !Array.isArray(params)) {
        return format;
    }
    return format.replace(/{(\d+)}/g, (match, p1) => {
        if (p1 in params) {
            return params[p1] == null ? "" : params[p1];
        }
        return match;
    });
}

/**
 * htmlのクラス属性構築ヘルパー。
 * <code>className('aaa xxx', {bbb: false, ccc: true})</code>は<code>"aaa xxx ccc"</code>となる。
 * @param base ベースのクラス。常に結果に含まれる。
 * @param conditional 条件付きで結果に含まれるクラス。オブジェクトの値がtrueならそのキーが含まれる
 * @returns {string} 構築されたクラス名
 */
function className(base, conditional) {
    if (conditional == null) {
        conditional = base;
        base = null;
    }
    return [base]
        .concat(Object.keys(conditional).filter((e) => conditional[e]))
        .filter((e) => e)
        .join(" ");
}

/**
 * 配列の最初の要素を返す
 * @param xs 配列
 * @returns {*|undefined} 最初の要素。xsがnull, undefined, 空配列の場合はundefined
 */
function first(xs) {
    return xs == null ? undefined : xs[0] || undefined;
}

/**
 * 配列の最後の要素を返す
 * @param xs 配列
 * @returns {*|undefined} 最後の要素。xsがnull, undefined, 空配列の場合はundefined
 */
function last(xs) {
    return xs == null || xs.length == null ? undefined : xs[xs.length - 1] || undefined;
}

/**
 * 関数か判定する。
 * @param x 判定する対象。
 * @returns {boolean} xが関数ならtrue
 */
function isFunction(x) {
    return typeof x === "function";
}

/**
 * 指定した方法で配列をソートする。
 * 非破壊の安定ソート。null or undefinedは末尾。
 * @param xs ソートする配列。null or undefinedは空配列とみなす。
 * @param conditions ソート条件の配列。配列の順の優先順位でソートする。要素は関数か文字列。
 *     関数の場合は関数の結果でソートする（Array.prototype.sortと同じ関数）。
 *     文字列の場合は<code>dig</code>で取り出してその値でソートする。
 * @param directions 文字列のascかdescでソート方向を指定する。conditionsと同じインデックスのソート順序を指定する。
 *     省略された場合や、当該インデックスの要素がない場合はasc。asc, desc以外もasc。
 *     この指定に関わらず、null or undefinedは末尾。また安定ソートに用いる元々の順序は常に昇順。
 * @returns {Array} ソートされた配列
 * @see dig
 */
function sortBy(xs, conditions, directions) {
    if (xs == null) {
        return [];
    }
    if (directions == null) {
        directions = [];
    }
    conditions = conditions.map((e) => (isFunction(e) ? e : (x) => dig(x, e)));
    return xs
        .map((e, i) => [e, i])
        .sort((a, b) => {
            for (let i = 0, n = conditions.length; i < n; ++i) {
                const condition = conditions[i];
                const direction = directions[i] === "desc" ? -1 : 1;

                const aValue = condition(a[0]);
                const bValue = condition(b[0]);
                if ((aValue == null && bValue == null) || aValue === bValue) {
                    continue;
                }
                if (aValue == null) {
                    return 1;
                }
                if (bValue == null) {
                    return -1;
                }
                return (aValue > bValue ? 1 : -1) * direction;
            }
            return a[1] - b[1];
        })
        .map((e) => e[0]);
}

/**
 * オブジェクトの指定したプロパティだけ残す。非破壊。
 * @param object オブジェクト
 * @param props 残すプロパティの配列
 * @returns {*}
 */
function pick(object, props) {
    if (object == null) {
        return {};
    }
    return props.reduce((a, e) => Object.assign(a, { [e]: object[e] }), {});
}

/**
 * オブジェクトの指定したプロパティを除去する。非破壊。
 * @param object オブジェクト
 * @param props 除去するプロパティの配列
 * @returns {*}
 */
function omit(object, props) {
    if (object == null) {
        return {};
    }
    props = new Set(props);
    return Object.entries(object).reduce((a, [k, v]) => (props.has(k) ? a : Object.assign(a, { [k]: v })), {});
}

/**
 * 配列の要素をユニークにする。つまり、重複する要素を除去する。
 * @param xs 配列
 * @returns {Array}
 */
function uniq(xs) {
    const checker = new Set();
    const result = [];
    for (const e of xs) {
        if (!checker.has(e)) {
            checker.add(e);
            result.push(e);
        }
    }
    return result;
}

/**
 * 2つの配列の差を取る。
 * @param a 配列
 * @param b 配列
 * @returns {Array} aからbに含まれる要素を除去した配列
 */
function difference(a, b) {
    a = a == null ? [] : a;
    b = new Set(b);

    const result = [];
    for (const e of a) {
        if (!b.has(e)) {
            result.push(e);
        }
    }
    return result;
}

/**
 * 2つの配列の交叉を取る。
 * @param a 配列
 * @param b 配列
 * @returns {Array} aとb両方に含まれる要素の配列。
 */
function intersection(a, b) {
    a = a == null ? [] : a;
    b = new Set(b);

    const result = [];
    for (const e of a) {
        if (b.has(e)) {
            result.push(e);
        }
    }
    return result;
}

/**
 * オブジェクトの配列を、要素のkeyプロパティでインデックスする。
 * @param array オブジェクトの配列
 * @param key インデックスキーとするプロパティ
 * @returns {*}
 */
function keyBy(array, key) {
    const keyFn = isFunction(key) ? key : (e) => e[key];
    return array.reduce((a, e) => Object.assign(a, { [keyFn(e)]: e }), {});
}

/**
 * オブジェクトの配列を、要素のkeyプロパティでグルーピングする。
 * @param array オブジェクトの配列
 * @param key グループキーとするプロパティ
 * @returns {*}
 */
function groupBy(array, key) {
    const keyFn = isFunction(key) ? key : (e) => e[key];
    return array.reduce((a, e) => {
        const groupKey = keyFn(e);
        if (groupKey in a) {
            a[groupKey].push(e);
        } else {
            a[groupKey] = [e];
        }
        return a;
    }, {});
}

/**
 * 文字列をUpperCamelCaseにする
 * @param x 文字列
 * @returns {string} UpperCamelCase
 */
function camelize(x) {
    if (!x) {
        return x;
    }
    return x[0].toUpperCase() + x.substring(1).replace(/_+([^_])/gi, (match, p1) => p1.toUpperCase());
}

// const col = [
// 	{label : '従業員名',fieldName: 'employeeName',format: (row) => row.employeeName__r.Name},
// 	{label: '役割',fieldName:POSITION_FIELD.fieldApiName},
// 	{label : '保有資格',fieldName: CERTIFICATION_FIELD.fieldApiName},
// 	{label:'受講履歴',fieldName:'seminarHistory',format:(row)=>row.employees__r.seminarName__c + row.employees__r.ConcreteDateTime__c }
// ]
// 		return [SELECT id,Name,employeeName__r.Name,(SELECT seminarName__c,ConcreteDateTime__c FROM employees__r),OwnedCertification__c,Position__c FROM employee__c];
// let arrayObj = [{key1:'value1', key2:'value2'},{key1:'value1', key2:'value2'}];

// arrayObj = arrayObj.map(item => {
//   return {
//     stroke: item.key1,
//     key2: item.key2
//   };
// });

function toTable(records, columns) {
	if (records == null) {
			return records;
	}
	const table = [];
	for (const record of records) {
			const row = { ...record };       
			for (const e of columns) {
					if (e.format) {
							row[e.fieldName] = e.format(row);
							console.log(e.fieldName,':',row[e.fieldName]);				
						}
			}
			table.push(row);	
	}
	return table;

}

export {
    Deferred,
    Awaiter,
    escapeRegEx,
    escapeHtml,
    trim,
    isBlank,
    splitByBlank,
    dig,
    coalesce,
    wait,
    debounce,
    caseSafeId,
    wrapArray,
    parseJsonSafe,
    formatMessage,
    className,
    first,
    last,
    isFunction,
    sortBy,
    pick,
    omit,
    uniq,
    difference,
    intersection,
    keyBy,
    groupBy,
    camelize,
		toTable
};