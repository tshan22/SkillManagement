import Deferred from "./deferred";

/**
 * 非同期処理の待ち合わせ。
 * コンストラクタの引数リストに指定した名前のプロパティにDeferredが設定される。
 * allプロパティは、それらがすべてresolveしたときに解決するPromise。
 * 例:
 *
 * ```
 * class MyElement extends LightningElement {
 *     awaiter = new Awaiter('connected', 'objectInfo');
 *
 *     @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
 *     wiredObjectInfo({ error, data }) {
 *         if (error) {
 *             ...
 *             return;
 *         }
 *         if (data) {
 *             ...
 *             this.awaiter.objectInfo.resolve();
 *         }
 *     }
 *
 *     async connectedCallback() {
 *         ...
 *         this.awaiter.connected.resolve();
 *
 *         await this.awaiter.all;
 *     }
 * }
 * ```
 */
export default class Awaiter {
    constructor(...names) {
        this._promises = [];
        for (const name of names) {
            this[name] = new Deferred();
            this._promises.push(this[name].promise);
        }
    }

    get all() {
        return Promise.all(this._promises);
    }

    get race() {
        return Promise.race(this._promises);
    }
}