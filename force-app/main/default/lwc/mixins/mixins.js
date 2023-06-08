import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { Deferred, camelize } from "c/util";
import { wire } from "lwc";
import {
    getObjectInfos,
    getObjectInfo,
    getPicklistValues,
    getPicklistValuesByRecordType
} from "lightning/uiObjectInfoApi";

// TODO: label
const ERROR_OCCURRED = "エラーが発生しました";

const showToastMixin = (superclass) =>
    class extends superclass {
        showExceptionToast(ex, defaultMessage = null) {
            console.error(ex);
            this.dispatchEvent(
                new ShowToastEvent({
                    message: (ex.body && ex.body.message) || defaultMessage || ERROR_OCCURRED,
                    variant: "error"
                })
            );
        }

        showToast(showToastEvent) {
            this.dispatchEvent(new ShowToastEvent(showToastEvent));
        }
    };

function _addWire(adaptor, args) {
    if (!this._remainingWires) {
        this._remainingWires = {};
    }
    if (this._remainingWires[adaptor] == null) {
        this._remainingWires[adaptor] = [];
    }
    const deferred = new Deferred();
    this._remainingWires[adaptor].push({ deferred, args });
    _wireNext.call(this, adaptor);
    return deferred.promise;
}

function _handleWire(adaptor, { data, error }) {
    if (error) {
        this._remainingWires[adaptor][0].deferred.reject(error);
    }
    if (data) {
        this._remainingWires[adaptor][0].deferred.resolve(data);
    }
    if (error || data) {
        _wireNext.call(this, adaptor, this._remainingWires[adaptor].shift());
    }
}

function _wireNext(adaptor, lastSeen) {
    if (!this._remainingWires[adaptor][0]) {
        Object.keys(lastSeen.args).forEach((key) => {
            this[`_wiring${camelize(adaptor)}${camelize(key)}`] = null;
        });
        return;
    }
    Object.entries(this._remainingWires[adaptor][0].args).forEach(([key, value]) => {
        this[`_wiring${camelize(adaptor)}${camelize(key)}`] = value;
    });
}

const getObjectInfosMixin = (superclass) =>
    class extends superclass {
        _wiringGetObjectInfosObjectApiNames;

        getObjectInfos(objectApiNames) {
            return _addWire.call(this, "getObjectInfos", { objectApiNames });
        }

        @wire(getObjectInfos, { objectApiNames: "$_wiringGetObjectInfosObjectApiNames" })
        _handleGetObjectInfos({ data, error }) {
            _handleWire.call(this, "getObjectInfos", { data, error });
        }
    };

const getObjectInfoMixin = (superclass) =>
    class extends superclass {
        _wiringGetObjectInfoObjectApiName;

        getObjectInfo(objectApiName) {
            return _addWire.call(this, "getObjectInfo", { objectApiName });
        }

        @wire(getObjectInfo, { objectApiName: "$_wiringGetObjectInfoObjectApiName" })
        _handleGetObjectInfo({ data, error }) {
            _handleWire.call(this, "getObjectInfo", { data, error });
        }
    };

const getPicklistValuesMixin = (superclass) =>
    class extends superclass {
        _wiringGetPicklistValuesRecordTypeId;
        _wiringGetPicklistValuesFieldApiName;

        getPicklistValues(recordTypeIdOrInfos, fieldApiName) {
            if (typeof recordTypeIdOrInfos === "string") {
                return _addWire.call(this, "getPicklistValues", { recordTypeId: recordTypeIdOrInfos, fieldApiName });
            } else {
                return Promise.all(
                    Object.values(recordTypeIdOrInfos).map(({ recordTypeId }) =>
                        this.getPicklistValues(recordTypeId, fieldApiName)
                    )
                );
            }
        }

        @wire(getPicklistValues, {
            recordTypeId: "$_wiringGetPicklistValuesRecordTypeId",
            fieldApiName: "$_wiringGetPicklistValuesFieldApiName"
        })
        _handleGetPicklistValues({ data, error }) {
            _handleWire.call(this, "getPicklistValues", { data, error });
        }
    };

const getPicklistValuesByRecordTypeMixin = (superclass) =>
    class extends superclass {
        _wiringGetPicklistValuesByRecordTypeRecordTypeId;
        _wiringGetPicklistValuesByRecordTypeObjectApiName;

        getPicklistValuesByRecordType(recordTypeIdOrInfos, objectApiName) {
            if (typeof recordTypeIdOrInfos === "string") {
                return _addWire.call(this, "getPicklistValuesByRecordType", {
                    recordTypeId: recordTypeIdOrInfos,
                    objectApiName
                });
            } else {
                return Promise.all(
                    Object.values(recordTypeIdOrInfos).map(({ recordTypeId }) =>
                        this.getPicklistValuesByRecordType(recordTypeId, objectApiName)
                    )
                );
            }
        }

        @wire(getPicklistValuesByRecordType, {
            recordTypeId: "$_wiringGetPicklistValuesByRecordTypeRecordTypeId",
            objectApiName: "$_wiringGetPicklistValuesByRecordTypeObjectApiName"
        })
        _handleGetPicklistValuesByRecordType({ data, error }) {
            _handleWire.call(this, "getPicklistValuesByRecordType", { data, error });
        }
    };

const openMenuMixin = (superclass) =>
    class extends superclass {
        disconnectedCallback() {
            if (this.outsideClickHandler) {
                this.outsideClickHandler.removeEventListener();
                this.outsideClickHandler = null;
            }
        }

        // should be overridden and call super
        onOutsideClick() {
            if (this.outsideClickHandler) {
                this.outsideClickHandler.removeEventListener();
                this.outsideClickHandler = null;
            }
        }

        stopPropagation(event) {
            event.stopImmediatePropagation();
        }

        registerOutsideClickHandler() {
            this.outsideClickHandler = {
                listener: () => {
                    this.onOutsideClick();
                },
                addEventListener: () => {
                    window.addEventListener("mousedown", this.outsideClickHandler.listener);
                },
                removeEventListener: () => {
                    window.removeEventListener("mousedown", this.outsideClickHandler.listener);
                }
            };
            this.outsideClickHandler.addEventListener();
        }

        openMenu(eventOrDOMRect, anchorElement, menuPosition, cb) {
            if (this.outsideClickHandler) {
                return;
            }
            cb(this._calcMenuPosition(anchorElement, eventOrDOMRect, menuPosition));
            this.registerOutsideClickHandler();
        }

        _calcMenuPosition(anchorElement, eventOrDOMRect, position) {
            const topLeft = anchorElement.getBoundingClientRect();
            const rect = eventOrDOMRect.currentTarget
                ? eventOrDOMRect.currentTarget.getBoundingClientRect()
                : eventOrDOMRect;
            const top = position.match(/^top/i) ? `${rect.y - topLeft.y}px` : "auto";
            const left = position.match(/left$/i) ? `${rect.x - topLeft.x}px` : "auto";
            const bottom = position.match(/^bottom/i) ? `${rect.bottom - topLeft.top}px` : "auto";
            const right = position.match(/right$/i) ? `${topLeft.right - rect.right}px` : "auto";

            return `position: absolute; top: ${top}; left: ${left}; bottom: ${bottom}; right: ${right};`;
        }
    };

export {
    showToastMixin,
    openMenuMixin,
    getObjectInfosMixin,
    getObjectInfoMixin,
    getPicklistValuesMixin,
    getPicklistValuesByRecordTypeMixin
};