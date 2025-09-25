import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	connect() {
		this.hideFlashAfterDelay()
	}

	hideFlashAfterDelay() {
		setTimeout(() => {
			this.close()
		}, 3000) // auto-hide after 3 seconds
	}

	close() {
		if (this.element && this.element.parentNode) {
			this.element.parentNode.removeChild(this.element)
		}
	}
}
