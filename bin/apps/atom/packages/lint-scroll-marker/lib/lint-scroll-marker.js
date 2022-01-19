const { CompositeDisposable } =  require("atom");
require('atom-package-deps').install('lint-scroll-marker');

const LintMessage = require("./LintMessage");

const editors = new Map();

var scrollMarker;
var oldMessages = [];


/**
 * Clears a layer based on a message and keeps track of
 * removed layers into an accumulator
 * @param  {Object} message       A message as received from the linter
 * @param  {Array} cleanedLeyers  An array that keeps already cleared layers
 * @return {undefined}
 */
async function clearLayerForMessage(message, cleanedLayers) {
	const lintMessage = new LintMessage(message);

	// check if we cleand this layer already
	if (cleanedLayers.indexOf(lintMessage.location.file) !== -1) {
		return;
	}

	const editor = editors.get(lintMessage.location.file);
	if (!editor) {
		return;
	}

	const errorMarkerLayer = scrollMarker.getLayer(editor, "lint-scroll-marker-error", "#fb392e");
	const warnMarkerLayer = scrollMarker.getLayer(editor, "link-scroll-marker-warn", "#fd8926");
	const infoMarkerLayer = scrollMarker.getLayer(editor, "link-scroll-marker-info", "rgba(20, 146, 255, 0.69)");

	await errorMarkerLayer.clear();
	await warnMarkerLayer.clear();
	await infoMarkerLayer.clear();

	cleanedLayers.push(lintMessage.location.file);
}


/**
 * Adds a marker to the editor for the file mentioned in the message
 * at the line mentioned in the message
 * @param {Object} message A message as received from the linter
 */
function addMarkerForMessage(message) {
	const lintMessage = new LintMessage(message);
	const editor = editors.get(lintMessage.location.file);
	if (!editor) {
		return;
	}

	const errorMarkerLayer = scrollMarker.getLayer(editor, "lint-scroll-marker-error", "#fb392e");
	const warnMarkerLayer = scrollMarker.getLayer(editor, "link-scroll-marker-warn", "#fd8926");
	const infoMarkerLayer = scrollMarker.getLayer(editor, "link-scroll-marker-info", "rgba(20, 146, 255, 0.69)");

	if(lintMessage.type === "Warning") {
		warnMarkerLayer.addMarker(lintMessage.location.position.start.row);
	}
	else if(lintMessage.type === "Info") {
		infoMarkerLayer.addMarker(lintMessage.location.position.start.row);
	}
	else {
		errorMarkerLayer.addMarker(lintMessage.location.position.start.row);
	}
}

module.exports = {

	subscriptions: null,

	activate() {
		this.subscriptions = new CompositeDisposable();

		this.subscriptions.add(atom.workspace.observeTextEditors(function(editor) {
			editors.set(editor.getPath(), editor);
		}));
	},

	provideUI() {
		return {
			name: 'Lint Scroll Marker',

			async render({ removed, messages }) {
				if (!scrollMarker) {
					return;
				}

				const cleanedLayers = [];
				for (const message of removed) {
					await clearLayerForMessage(message, cleanedLayers);
				}

				for (const message of messages) {
					addMarkerForMessage(message);
				}
			},

			didBeginLinting() {},
			didFinishLinting() {},
			dispose() {}
		};
	},

	async consumeDiagnosticUpdates(diagnosticUpdater) {
		this.subscriptions.add(diagnosticUpdater.observeMessages(async function(messages) {

			const cleanedLayers = [];
			for (const oldMessage of oldMessages) {
				if (!messages.includes(oldMessage)) {
					await clearLayerForMessage(oldMessage, cleanedLayers);
				}
			}

			for (const message of messages) {
				addMarkerForMessage(message);
			}

			oldMessages = messages;
		}));
	},

	consumeScrollMarker(scrollMarkerAPI) {
		scrollMarker = scrollMarkerAPI;
	},

	deactivate() {
		this.subscriptions.dispose();
		editors.clear();
	}
};
