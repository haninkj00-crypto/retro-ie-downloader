// Register the context menu only on install or update
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "ie_download",
    title: "Download via Legacy IE",
    contexts: ["link"]
  });
});

// Click event listener must be at the top level 
// so the Service Worker can reliably wake up and handle events.
chrome.contextMenus.onClicked.addListener((info) => {
  if (info.menuItemId === "ie_download") {
    const port = chrome.runtime.connectNative('com.dowon.urlmon_bridge');
    port.postMessage({ url: info.linkUrl });
    
    port.onDisconnect.addListener(() => {
      if (chrome.runtime.lastError) {
        console.error("Native Host connection failed:", chrome.runtime.lastError.message);
      }
    });
  }
});