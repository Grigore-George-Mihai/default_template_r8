import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  closeOthers() {
    if (!this.element.open) return
    document.querySelectorAll("details[data-controller~='base--dropdown']").forEach(el => {
      if (el !== this.element) el.open = false
    })
  }
}
