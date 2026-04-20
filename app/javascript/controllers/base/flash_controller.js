import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  connect() {
    this.hideFlashAfterDelay()
  }

  hideFlashAfterDelay() {
    setTimeout(() => this.close(), 3000)
  }

  close() {
    this.element.remove()
  }
}
