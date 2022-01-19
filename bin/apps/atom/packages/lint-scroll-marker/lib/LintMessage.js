class LintMessage {
	constructor(message) {
		Object.assign(this, message);

		if (this.filePath) {
			this.location = {
				file: this.filePath,
				position: this.range
			};

			delete this.filePath;
			delete this.range;
		}
	}
}

module.exports = LintMessage;
