import QtQuick
import Quickshell
import qs.Services.Noctalia

ShellRoot {
    Component.onCompleted: {
        console.log("=== PLUGINS DIR ===");
        console.log(PluginRegistry.pluginsDir);
        
        console.log("=== ALL INSTALLED PLUGINS ===");
        var ids = PluginRegistry.getAllInstalledPluginIds();
        console.log(JSON.stringify(ids));
        
        for (var i = 0; i < ids.length; i++) {
            console.log("Plugin:", ids[i], "=>", JSON.stringify(PluginRegistry.getPluginManifest(ids[i])));
        }
        
        console.log("=== MANIFEST LOAD TEST ===");
        PluginRegistry.loadPluginManifest("chillpill-blob");
        
        Quickshell.exit(0);
    }
}
