const { CompositeDisposable } =  require("atom");
var scrollMarker;

require('atom-package-deps').install('find-scroll-marker');

module.exports = {

	subscriptions: null,

	activate() {
		this.subscriptions = new CompositeDisposable();
	},

	consumeFind(findService) {
		this.subscriptions.add(atom.workspace.observeTextEditors(function(editor) {
			if (!scrollMarker) {
				return;
			}

			const searchMarkerLayer = findService.resultsMarkerLayerForTextEditor(editor);
			const scrollMarkerLayer = scrollMarker.getLayer(editor, "find-marker-layer", "#ffdd00");

			scrollMarkerLayer.syncToMarkerLayer(searchMarkerLayer);
		}));
	},

	consumeScrollMarker(scrollMarkerAPI) {
		scrollMarker = scrollMarkerAPI;
	},

	deactivate() {
		this.subscriptions.dispose();
	}
};
