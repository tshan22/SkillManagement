/**
 * 外から解決できるPromise
 */
export default class Deferred {
	constructor() {
			this._promise = new Promise((resolve, reject) => {
					this._resolve = resolve;
					this._reject = reject;
			});
	}

	get promise() {
			return this._promise;
	}

	resolve(value) {
			this._resolve(value);
	}

	reject(reason) {
			this._reject(reason);
	}
}