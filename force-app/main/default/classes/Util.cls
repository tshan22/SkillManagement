public class Util {
	/**
	 * 一度参照すると変化しない現在時刻（ミリ秒以下切り捨て）
	 */
	@TestVisible
	public static Datetime NOW {
			get {
					if (NOW == null) {
							NOW = truncateMillisecond(System.now());
					}
					return NOW;
			}
			private set {
					NOW = truncateMillisecond(value);
					TODAY_MIDNIGHT = null;
					TOMORROW_MIDNIGHT = null;
			}
	}

	/**
	 * 今日の深夜0時（ローカル時間）
	 */
	public static Datetime TODAY_MIDNIGHT {
			get {
					if (TODAY_MIDNIGHT == null) {
							TODAY_MIDNIGHT = toMidnightLocal(NOW);
					}
					return TODAY_MIDNIGHT;
			}
			private set;
	}

	/**
	 * 明日の深夜0時（ローカル時間）
	 */
	public static Datetime TOMORROW_MIDNIGHT {
			get {
					if (TOMORROW_MIDNIGHT == null) {
							TOMORROW_MIDNIGHT = TODAY_MIDNIGHT.addDays(1);
					}
					return TOMORROW_MIDNIGHT;
			}
			private set;
	}

	/**
	 * 深夜0時
	 */
	public static Time MIDNIGHT {
			get {
					if (MIDNIGHT == null) {
							MIDNIGHT = Time.newInstance(0, 0, 0, 0);
					}
					return MIDNIGHT;
			}
			private set;
	}

	/**
	 * ローカル時間のUTCオフセットを秒で返す。
	 */
	@TestVisible
	public static Integer UTC_OFFSET_SECONDS {
			get {
					if (UTC_OFFSET_SECONDS == null) {
							Datetime utc = Datetime.newInstanceGmt(NOW.date(), NOW.time());
							UTC_OFFSET_SECONDS = Integer.valueOf((utc.getTime() - NOW.getTime()) / 1000L);
					}
					return UTC_OFFSET_SECONDS;
			}
			private set;
	}

	/**
	 * SObjectに保存できる最小の日時。
	 */
	public static Datetime MIN_DATETIME {
			get {
					if (MIN_DATETIME == null) {
							MIN_DATETIME = Datetime.newInstanceGmt(1700, 1, 1, 0, 0, 0);
					}
					return MIN_DATETIME;
			}
			private set;
	}

	/**
	 * SObjectに保存できる最大の日時。
	 */
	public static Datetime MAX_DATETIME {
			get {
					if (MAX_DATETIME == null) {
							MAX_DATETIME = Datetime.newInstanceGmt(4000, 12, 31, 0, 0, 0);
					}
					return MAX_DATETIME;
			}
			private set;
	}

	// Object保存時にトリムされるホワイトスペース
	private static String WHITESPACE_REGEX {
			get {
					if (WHITESPACE_REGEX == null) {
							WHITESPACE_REGEX = '[\\x00-\\x20\\u1680\\u180E\\u2000-\\u2006\\u2008-\\u200A\\u2028\\u2029\\u205F\\u3000]';
					}
					return WHITESPACE_REGEX;
			}
			set;
	}

	// Object保存時にトリムされるホワイトスペースが先頭に連続する
	private static Pattern LEADING_WHITESPACE {
			get {
					if (LEADING_WHITESPACE == null) {
							String regex = '^' + WHITESPACE_REGEX + '+';
							LEADING_WHITESPACE = Pattern.compile(regex);
					}
					return LEADING_WHITESPACE;
			}
			set;
	}

	// Object保存時にトリムされるホワイトスペースが末尾に連続する
	private static Pattern TRAILING_WHITESPACE {
			get {
					if (TRAILING_WHITESPACE == null) {
							String regex = WHITESPACE_REGEX + '+$';
							TRAILING_WHITESPACE = Pattern.compile(regex);
					}
					return TRAILING_WHITESPACE;
			}
			set;
	}

	// Object保存時にトリムされるホワイトスペースの連続
	private static Pattern REPEATING_WHITESPACE {
			get {
					if (REPEATING_WHITESPACE == null) {
							String regex = WHITESPACE_REGEX + '+';
							REPEATING_WHITESPACE = Pattern.compile(regex);
					}
					return REPEATING_WHITESPACE;
			}
			set;
	}

	// Object保存時にトリムされるホワイトスペースの連続
	private static Pattern BLANK_PATTERN {
			get {
					if (BLANK_PATTERN == null) {
							String regex = '^' + WHITESPACE_REGEX + '+$';
							BLANK_PATTERN = Pattern.compile(regex);
					}
					return BLANK_PATTERN;
			}
			set;
	}

	/**
	 * ミリ秒以下を切り捨てる。
	 * SObjectに保存すると切り捨てられるので、比較時など保存せず切り捨てておきたいときに使用する。
	 * @param x ミリ秒以下を切り捨てる日付時刻
	 *
	 * @return ミリ秒以下を切り捨てた日付時刻
	 */
	public static Datetime truncateMillisecond(Datetime x) {
			return x == null ? null : Datetime.newInstance(x.year(), x.month(), x.day(), x.hour(), x.minute(), x.second());
	}

	/**
	 * 日時を深夜0時に移動する（ローカル時間）
	 * @param x この日の深夜0時
	 *
	 * @return xの深夜0時。
	 */
	public static Datetime toMidnightLocal(Datetime x) {
			return x == null ? null : toMidnightLocal(x.date());
	}

	/**
	 * 日の深夜0時を返す（ローカル時間）
	 * @param x この日の深夜0時
	 *
	 * @return xの深夜0時。
	 */
	public static Datetime toMidnightLocal(Date x) {
			return x == null ? null : Datetime.newInstance(x, MIDNIGHT);
	}

	/**
	 * レコードのListの各要素の、指定したId項目のSetを返す。nullは含まない
	 * @param xs レコードのList
	 * @param keyField Id項目
	 *
	 * @return xsの各要素のkeyField項目のSet
	 */
	public static Set<Id> pickId(SObject[] xs, Schema.SObjectField keyField) {
			Set<Id> result = new Set<Id>();
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					Id value = (Id) e.get(keyField);
					if (value != null) {
							result.add(value);
					}
			}
			return result;
	}

	/**
	 * レコードのListの各要素の、指定した文字列項目のSetを返す。ブランクは含まない
	 * @param xs レコードのList
	 * @param keyField 文字列項目
	 *
	 * @return xsの各要素のkeyField項目のSet
	 */
	public static Set<String> pickString(SObject[] xs, Schema.SObjectField keyField) {
			Set<String> result = new Set<String>();
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					String value = (String) e.get(keyField);
					if (!String.isBlank(value)) {
							result.add(value);
					}
			}
			return result;
	}

	/**
	 * レコードのListの各要素の、指定したId項目の参照先レコードを返す。nullは含まない
	 * 例: <code>Util.pickSObject([SELECT Id, Account.Id FROM Contact], Contact.AccountId)</code>
	 * @param xs レコードのList
	 * @param keyField Id項目
	 *
	 * @return xsの各要素のkeyField項目の参照先のList。Account[]などにはキャストできないことに注意。
	 */
	public static SObject[] pickSObject(SObject[] xs, Schema.SObjectField keyField) {
			SObject[] result = new List<SObject>{};
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					SObject value = e.getSObject(keyField);
					if (value != null) {
							result.add(value);
					}
			}
			return result;
	}

	/**
	 * レコードのListの各要素の、指定したId項目で参照される参照元レコードを返す。
	 * 例: <code>Util.pickSObjects([SELECT Id, (SELECT Id FROM Contacts) FROM Account], Contact.AccountId)</code>
	 * @param xs レコードのList
	 * @param keyField 参照元のId項目
	 *
	 * @return xsの各要素のkeyField項目で参照される参照元のList。Contact[]などにはキャストできないことに注意。
	 */
	public static SObject[] pickSObjects(SObject[] xs, Schema.SObjectField keyField) {
			SObject[] result = new List<SObject>{};
			if (isEmpty(xs)) {
					return result;
			}
			// getSObjects(SObjectField)の方はSalesforce System ErrorになるのでgetSObjects(String field)を使う。
			for (ChildRelationship rel : xs.getSObjectType().getDescribe().getChildRelationships()) {
					if (rel.field == keyField) {
							for (SObject e : xs) {
									SObject[] values = e.getSObjects(rel.relationshipName);
									if (values != null) {
											result.addAll(values);
									}
							}
							return result;
					}
			}
			throw new SObjectException();
	}

	/**
	 * レコードのListを、指定したId項目でグルーピングする。
	 * 例: <code>Util.groupById([SELECT Id, AccountId FROM Contact], Contact.AccountId)</code>
	 * @param xs レコードのList
	 * @param keyField グループキーとするId項目
	 *
	 * @return キーがId項目の値、値が同じId項目値を持つレコードのListとなるMap。値はContact[]などにキャストできないので注意。
	 */
	public static Map<Id, SObject[]> groupById(SObject[] xs, Schema.SObjectField keyField) {
			Map<Id, SObject[]> result = new Map<Id, SObject[]>();
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					Id key = (Id) e.get(keyField);
					SObject[] records = result.get(key);
					if (records == null) {
							result.put(key, new List<SObject>{ e });
					} else {
							records.add(e);
					}
			}
			return result;
	}

	/**
	 * レコードのListを、指定した文字列項目でグルーピングする。
	 * 例: <code>Util.groupByString([SELECT Id, ProductCode FROM Product2], Product2.ProductCode)</code>
	 * @param xs レコードのList
	 * @param keyField グループキーとする文字列項目
	 *
	 * @return キーが文字列項目の値、値が同じ文字列項目値を持つレコードのListとなるMap。値はContact[]などにキャストできないので注意。
	 */
	public static Map<String, SObject[]> groupByString(SObject[] xs, Schema.SObjectField keyField) {
			Map<String, SObject[]> result = new Map<String, SObject[]>();
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					String key = (String) e.get(keyField);
					if (String.isBlank(key)) {
							key = '';
					}
					SObject[] records = result.get(key);
					if (records == null) {
							result.put(key, new List<SObject>{ e });
					} else {
							records.add(e);
					}
			}
			return result;
	}

	/**
	 * レコードのListを、指定したId項目でインデックスする。
	 * 例: <code>Util.keyById([SELECT Id, AccountId FROM Contact], Contact.AccountId)</code>
	 * @param xs レコードのList
	 * @param keyField キーとするId項目
	 *
	 * @return キーがId項目の値、値がそのId項目値を持つレコードとなるMap。キーの重複は後勝ち。nullもキーとなる。
	 */
	public static Map<Id, SObject> keyById(SObject[] xs, Schema.SObjectField keyField) {
			Map<Id, SObject> result = new Map<Id, SObject>();
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					Id key = (Id) e.get(keyField);
					result.put(key, e);
			}
			return result;
	}

	/**
	 * レコードのListを、指定した文字列項目でインデックスする。
	 * 例: <code>Util.keyByString([SELECT Id, ProductCode FROM Product2], Product2.ProductCode)</code>
	 * @param xs レコードのList
	 * @param keyField キーとする文字列項目
	 *
	 * @return キーが文字列項目の値、値がその文字列項目値を持つレコードとなるMap。キーの重複は後勝ち。キーがブランクの場合空文字列をキーとする
	 */
	public static Map<String, SObject> keyByString(SObject[] xs, Schema.SObjectField keyField) {
			Map<String, SObject> result = new Map<String, SObject>();
			if (isEmpty(xs)) {
					return result;
			}
			for (SObject e : xs) {
					String key = (String) e.get(keyField);
					if (String.isBlank(key)) {
							key = '';
					}
					result.put(key, e);
			}
			return result;
	}

	/**
	 * リストの空チェック。nullか空ならtrue
	 * @param xs リスト
	 *
	 * @return リストがnullか空ならtrue
	 */
	public static Boolean isEmpty(Object[] xs) {
			return xs == null || xs.isEmpty();
	}

	/**
	 * リストの最初の要素
	 * @param xs リスト
	 *
	 * @return リストの最初の要素。リストがnullか空ならnull
	 */
	public static Object firstOrNull(Object[] xs) {
			if (isEmpty(xs)) {
					return null;
			}
			return xs[0];
	}

	/**
	 * リストの最後の要素
	 * @param xs リスト
	 *
	 * @return リストの最後の要素。リストがnullか空ならnull
	 */
	public static Object lastOrNull(Object[] xs) {
			if (isEmpty(xs)) {
					return null;
			}
			return xs[xs.size() - 1];
	}

	/**
	 * リストの最初のnullでない要素を返す。
	 * @param xs リスト
	 *
	 * @return リストの最初のnullでない要素。リストがnullか、非nullを含まないならnull
	 */
	public static Object coalesce(Object[] xs) {
			if (isEmpty(xs)) {
					return null;
			}
			for (Object e : xs) {
					if (e != null) {
							return e;
					}
			}
			return null;
	}

	/**
	 * リストの最初のブランクでない要素を返す。
	 * @param xs リスト
	 *
	 * @return リストの最初のnullでない要素。リストがnullか、非ブランクを含まないならnull
	 */
	public static String coalesce(String[] xs) {
			if (isEmpty(xs)) {
					return null;
			}
			for (String e : xs) {
					if (!String.isBlank(e)) {
							return e;
					}
			}
			return null;
	}

	/**
	 * 文字列がnullなら空文字列を返す。
	 * @param x 文字列
	 *
	 * @return 文字列がnullなら空文字列、それ以外はそのまま
	 */
	public static String nullAsEmpty(String x) {
			return x == null ? '' : x;
	}

	/**
	 * 文字列がブランクならnullを返す。
	 * @param x 文字列
	 *
	 * @return 文字列がブランクならnull、それ以外はそのまま
	 */
	public static String blankAsNull(String x) {
			return isBlank(x) ? null : x;
	}

	/**
	 * 数値がnullなら0を返す
	 * @param x 数値
	 *
	 * @return 数値がnullなら0、それ以外はそのまま
	 */
	public static Decimal nullAsZero(Decimal x) {
			return x == null ? 0 : x;
	}

	/**
	 * リストからnullを除外する。非破壊
	 * @param xs リスト
	 *
	 * @return xsからnullを除外したリスト。xsがnullならnull（空のリストではない。戻り値のキャストでTypeExceptionを発生させないための措置）
	 */
	public static Object[] rejectNull(Object[] xs) {
			Object[] result = cloneAndClear(xs);
			if (isEmpty(xs)) {
					return result;
			}
			for (Object e : xs) {
					if (e != null) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * リストからブランクを除外する。非破壊
	 * @param xs リスト
	 *
	 * @return xsからブランクを除外したリスト。xsがnullならnull（空のリストではない。rejectNull(Object[])にあわせている）
	 */
	public static String[] rejectBlank(String[] xs) {
			String[] result = new List<String>{};
			if (isEmpty(xs)) {
					return result;
			}
			for (String e : xs) {
					if (!String.isBlank(e)) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * Mapからnull値を除外する。非破壊
	 * @param xs Map
	 *
	 * @return xsからnull値を除外したMap。xsがnullならnull（空のMapではない。戻り値のキャストでTypeExceptionを発生させないための措置）
	 */
	public static Map<String, Object> rejectBlankValue(Map<String, Object> xs) {
			Map<String, Object> result = cloneAndClear(xs);
			if (xs == null) {
					return result;
			}
			for (String key : xs.keySet()) {
					Object value = xs.get(key);
					if (value != null) {
							result.put(key, value);
					}
			}
			return result;
	}

	/**
	 * Mapからブランク値を除外する。非破壊
	 * @param xs Map
	 *
	 * @return xsからブランク値を除外したMap。xsがnullならnull（空のMapではない。rejectBlankValue(Map<String, Object>)にあわせている）
	 */
	public static Map<String, String> rejectBlankValue(Map<String, String> xs) {
			Map<String, String> result = new Map<String, String>();
			if (xs == null) {
					return result;
			}
			for (String key : xs.keySet()) {
					String value = xs.get(key);
					if (!String.isBlank(value)) {
							result.put(key, value);
					}
			}
			return result;
	}

	/**
	 * リストの右から指定したサイズの要素を取得する。
	 * @param xs リスト
	 * @param size サイズ。負数は0とみなす。
	 *
	 * @return リストの右から指定したサイズの要素からなる配列。順序はそのまま。サイズがリストより大きい場合はすべての要素。
	 *     xsがnullならnullを返す（空のListではない。戻り値のキャストでTypeExceptionを発生させないための措置）
	 */
	public static Object[] takeRight(Object[] xs, Integer size) {
			Object[] result = cloneAndClear(xs);
			if (isEmpty(xs) || size <= 0) {
					return result;
			}
			for (Integer i = Math.max(xs.size() - size, 0), n = xs.size(); i < n; ++i) {
					result.add(xs[i]);
			}
			return result;
	}

	/**
	 * リストの指定したindex以降の要素を取得
	 * @param xs リスト
	 * @param beginIndex 開始index。負数は0とみなす。
	 *
	 * @return リストの指定したindex以降の要素からなる配列。順序はそのまま。
	 *     xsがnullならnullを返す（空のListではない。戻り値のキャストでTypeExceptionを発生させないための措置）
	 */
	public static Object[] slice(Object[] xs, Integer beginIndex) {
			if (xs == null) {
					return null;
			}
			return slice(xs, beginIndex, xs.size());
	}

	/**
	 * リストの指定した範囲の要素を取得
	 * @param xs リスト
	 * @param beginIndex 開始index。負数は0とみなす。
	 * @param endIndex 終了index（このindexを含まない）。範囲外なら最後の要素までとする。
	 *
	 * @return リストの指定した範囲の要素からなる配列。順序はそのまま。開始が範囲外、終了<開始の場合は空の配列。
	 *     xsがnullならnullを返す（空のListではない。戻り値のキャストでTypeExceptionを発生させないための措置）
	 */
	public static Object[] slice(Object[] xs, Integer beginIndex, Integer endIndex) {
			Object[] result = cloneAndClear(xs);
			if (isEmpty(xs)) {
					return result;
			}
			for (Integer i = Math.max(0, Math.min(beginIndex, xs.size())), n = Math.min(endIndex, xs.size()); i < n; ++i) {
					result.add(xs[i]);
			}
			return result;
	}

	/**
	 * リストを指定したサイズで分割する
	 * @param xs リスト
	 * @param size 分割するサイズ
	 *
	 * @return リストを指定したサイズで分割したリスト。つまりリストのリスト。xsがnull，またはサイズが0以下の場合は空のリストを返す。
	 */
	public static Object[] chunk(Object[] xs, Integer size) {
			List<Object[]> result = new List<Object[]>();
			if (xs == null || size <= 0) {
					return result;
			}
			for (Integer i = 0, n = xs.size(); i < n; i += size) {
					result.add(slice(xs, i, i + size));
			}
			return result;
	}

	/**
	 * JSON.deserializeUntypedしたオブジェクトまたは配列から値を取り出す。
	 * dig(JSON.deserializeUntyped(jsonString), 'a.b.0.c')は、
	 * Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
	 * Map<String, Object> a = (Map<String, Object>) root.get('a');
	 * Object[] b = (Object[]) a.get('b');
	 * Map<String, Object> zero = (Map<String, Object>) b[0];
	 * zero.get('c');
	 * と同じ。ただし、途中でnullやデータ型の違いなどで探索できなくなったときはnullを返す。
	 * @param x JSON.deserializeUntypedしたオブジェクトまたは配列
	 * @param path 探索するパス
	 *
	 * @return オブジェクトの、パスで指定したフィールド。
	 */
	public static Object dig(Object x, String path) {
			Object current = x;
			for (String prop : path.split('\\.')) {
					if (current == null) {
							return null;
					} else if (current instanceof List<Object>) {
							if (!prop.isNumeric()) {
									return null;
							}
							Object[] currentAsList = (Object[]) current;
							Integer index = Integer.valueOf(prop);
							if (currentAsList.size() <= index) {
									return null;
							}
							current = currentAsList[index];
					} else if (current instanceof Map<String, Object>) {
							Map<String, Object> currentAsMap = (Map<String, Object>) current;
							current = currentAsMap.get(prop);
					} else {
							return null;
					}
			}
			return current;
	}

	/**
	 * SObject保存時のホワイトスペース除去と同等の処理
	 * @param x 文字列
	 *
	 * @return xの前後のホワイトスペースを除去した文字列。xがnullのときは空文字列。
	 */
	public static String trim(String x) {
			if (String.isBlank(x)) {
					return '';
			}
			x = LEADING_WHITESPACE.matcher(x).replaceFirst('');
			return TRAILING_WHITESPACE.matcher(x).replaceFirst('');
	}

	/**
	 * ホワイトスペースで分割。ホワイトスペースとはSObjectに保存したときトリムされる文字を指す。
	 * @param x 文字列。前後のホワイトスペースは除去する。
	 *
	 * @return xを連続するホワイトスペースで分割した文字列配列。xがnull, 空文字列、ホワイトスペースのみの文字列の場合は空配列。
	 */
	public static String[] splitByBlank(String x) {
			if (String.isBlank(x)) {
					return new List<String>();
			}
			return REPEATING_WHITESPACE.split(trim(x));
	}

	/**
	 * ホワイトスペースで分割。ホワイトスペースとはSObjectに保存したときトリムされる文字を指す。
	 * @param x 文字列。前後のホワイトスペースは除去する。
	 * @param n 最大分割数
	 *
	 * @return xを連続するホワイトスペースで分割した文字列配列。xがnull, 空文字列、ホワイトスペースのみの文字列の場合は空配列。
	 */
	public static String[] splitByBlank(String x, Integer n) {
			if (String.isBlank(x)) {
					return new List<String>();
			}
			return REPEATING_WHITESPACE.split(trim(x), n);
	}

	/**
	 * 文字列のブランク判定。ブランクとはSObjectに保存したときnullになることを指す。
	 * @param x 文字列
	 *
	 * @return xがSObjectに保存したときnullになる文字列かnullの場合true
	 */
	public static Boolean isBlank(String x) {
			if (x == null) {
					return true;
			}
			return BLANK_PATTERN.matcher(x).matches();
	}

	/**
	 * SOQL特殊文字をエスケープする。制御文字は除去する。
	 * @see https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_quotedstringescapes.htm
	 * @param x 文字列
	 *
	 * @return xのSQOL特殊文字をエスケープした文字列。制御文字は除去。xがnullの場合はnullを返す
	 */
	public static String escapeForSoql(String x) {
			return x == null ? null : x.replaceAll('([\\\\\'"])', '\\\\$1').replaceAll('\\p{Cntrl}', '');
	}

	/**
	 * SOQL特殊文字をエスケープする。LIKE用。制御文字は除去する。
	 * @see https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_quotedstringescapes.htm
	 * @param x 文字列
	 *
	 * @return xのSQOL LIKE特殊文字をエスケープした文字列。制御文字は除去。xがnullの場合はnullを返す
	 */
	public static String escapeForSoqlLike(String x) {
			return x == null ? null : x.replaceAll('([\\\\\'"%_])', '\\\\$1').replaceAll('\\p{Cntrl}', '');
	}

	/**
	 * SOSL特殊文字をエスケープする。制御文字は除去する。
	 * @see https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_find.htm
	 * @param x 文字列
	 *
	 * @return xのSQSL特殊文字をエスケープした文字列。制御文字は除去。xがnullの場合はnullを返す
	 */
	public static String escapeForSosl(String x) {
			return x == null
							? null
							: x.replaceAll('([\\?&\\|!\\{\\}\\[\\]\\(\\)\\^~\\*:\\\\"\'\\+\\-])', '\\\\$1')
											.replaceAll('\\p{Cntrl}', '');
	}

	/**
	 * アクティブなPicklistEntryを返す。
	 * @param field 選択リスト項目
	 *
	 * @return 項目のアクティブなPicklistEntry
	 */
	public static PicklistEntry[] activeEntry(SObjectField field) {
			PicklistEntry[] result = new List<PicklistEntry>{};
			for (PicklistEntry e : field.getDescribe().picklistValues) {
					if (e.active) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * 2つのSetの差を取る。
	 * @param a Set。null不可
	 * @param b Set。null不可
	 *
	 * @return aからbに含まれる要素を除去したSet
	 */
	public static Set<Id> difference(Set<Id> a, Set<Id> b) {
			Set<Id> result = new Set<Id>();
			for (Id e : a) {
					if (!b.contains(e)) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * 2つのSetの差を取る。
	 * @param a Set。null不可
	 * @param b Set。null不可
	 *
	 * @return aからbに含まれる要素を除去したSet
	 */
	public static Set<String> difference(Set<String> a, Set<String> b) {
			Set<String> result = new Set<String>();
			for (String e : a) {
					if (!b.contains(e)) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * 2つのSetの交叉を取る。
	 * @param a Set。null不可
	 * @param b Set。null不可
	 *
	 * @return aとb両方に含まれる要素のSet
	 */
	public static Set<Id> intersection(Set<Id> a, Set<Id> b) {
			Set<Id> result = new Set<Id>();
			for (Id e : a) {
					if (b.contains(e)) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * 2つのSetの交叉を取る。
	 * @param a Set。null不可
	 * @param b Set。null不可
	 *
	 * @return aとb両方に含まれる要素のSet
	 */
	public static Set<String> intersection(Set<String> a, Set<String> b) {
			Set<String> result = new Set<String>();
			for (String e : a) {
					if (b.contains(e)) {
							result.add(e);
					}
			}
			return result;
	}

	/**
	 * 配列の要素をユニークにする。つまり、重複する要素を除去する。
	 * @param xs 配列。null不可
	 *
	 * @return 重複する要素を除去した配列。
	 */
	public static Id[] uniq(Id[] xs) {
			return new List<Id>(new Set<Id>(xs));
	}

	/**
	 * 配列の要素をユニークにする。つまり、重複する要素を除去する。
	 * @param xs 配列。null不可
	 *
	 * @return 重複する要素を除去した配列。
	 */
	public static String[] uniq(String[] xs) {
			return new List<String>(new Set<String>(xs));
	}

	/**
	 * destにsrcの項目をコピーする。破壊的。
	 * @param dest コピー先。null不可
	 * @param src コピー元。null不可
	 *
	 * @return dest。両方に含まれる項目があるならコピー元優先。
	 */
	public static SObject assign(SObject dest, SObject src) {
			Map<String, Object> srcFields = src.getPopulatedFieldsAsMap();
			for (String e : srcFields.keySet()) {
					dest.put(e, srcFields.get(e));
			}
			return dest;
	}

	/**
	 * destにsrcのキー・値ペアをコピーする。破壊的。
	 * @param dest コピー先。null不可
	 * @param src コピー元。null不可
	 *
	 * @return dest。両方に含まれるキーがあるならコピー元優先。
	 */
	public static Map<String, Object> assign(Map<String, Object> dest, Map<String, Object> src) {
			for (String e : src.keySet()) {
					dest.put(e, src.get(e));
			}
			return dest;
	}

	/**
	 * 配列を連結する。
	 * @param a 配列。null不可
	 * @param b 配列。null不可
	 *
	 * @return aとbを連結した配列
	 */
	public static Id[] concat(Id[] a, Id[] b) {
			return (Id[]) concat((Object[]) a, (Object[]) b);
	}

	/**
	 * 配列を連結する。
	 * @param a 配列。null不可
	 * @param b 配列。null不可
	 *
	 * @return aとbを連結した配列
	 */
	public static String[] concat(String[] a, String[] b) {
			return (String[]) concat((Object[]) a, (Object[]) b);
	}

	/**
	 * 配列を連結する。
	 * @param a 配列。null不可
	 * @param b 配列。null不可
	 *
	 * @return aとbを連結した配列
	 */
	public static Object[] concat(Object[] a, Object[] b) {
			Object[] result = cloneAndClear(a);
			result.addAll(a);
			result.addAll(b);
			return result;
	}

	// 戻り値をキャストするときのTypeException対策
	private static Object[] cloneAndClear(Object[] xs) {
			if (xs == null) {
					return null;
			}
			Object[] result = xs.clone();
			result.clear();
			return result;
	}

	// 戻り値をキャストするときのTypeException対策
	private static Map<String, Object> cloneAndClear(Map<String, Object> xs) {
			if (xs == null) {
					return null;
			}
			Map<String, Object> result = xs.clone();
			result.clear();
			return result;
	}
}