import { api, LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import pubsub from "vlocity_cmt/pubsub";

export default class B2bNextStepsAction extends NavigationMixin(LightningElement) {
	@api set record(val) {
		this._record = val;
	}

	get record() {
		return this._record;
	}

	get isButton() {
		return this.record.actionType === "Button";
	}

	get isLink() {
		return this.record.actionType === "Link";
	}

	get isText() {
		return this.record.actionType === "Text";
	}

	nextStepsAction() {
		pubsub.fire("next-step-action", "data", null);

		if (this.record.actionTarget === "Omniscript") {
			let url = window.location.href;
			let baseUrl = url.substring(0, url.indexOf("/lightning"));
			let omniUrl =
				baseUrl +
				"/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?&c__layout=lightning&c__target=" +
				this.record.actionTargetName;
			let actionParam = JSON.parse(this.record.actionParameters);
			for (let key in actionParam) {
				let paramKey = key + "=" + actionParam[key];
				omniUrl += "&" + paramKey;
			}
			this[NavigationMixin.Navigate]({
				type: "standard__webPage",
				attributes: {
					url: omniUrl,
				},
			});
		} else if (this.record.actionTarget === "RecordPage") {
			let url = window.location.href;
			let baseUrl = url.substring(0, url.indexOf("/lightning"));
			let actionParam = JSON.parse(this.record.actionParameters);
			let recordUrl = baseUrl + "/" + actionParam.Id;
			this[NavigationMixin.Navigate]({
				type: "standard__webPage",
				attributes: {
					url: recordUrl,
				},
			});
		}
	}
}