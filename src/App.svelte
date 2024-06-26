<script>
    import {onMount} from 'svelte';
    import {writable} from 'svelte/store';
    import {fade} from 'svelte/transition';

    let isConnected = writable(false);
    let isStarted = writable(false);
    let isModuleLoaded = writable(false); // State to track if the module is loaded
    let bootstrapAddresses = "";
    let peerID = null;
    let networkHead = null;
    let notification = null
    let connectedPeers = null
    let syncer = null

    window.addEventListener('unhandledrejection', event => {
        event.preventDefault();
    });

    window.addEventListener('error', (event) => {
        console.error('Global error handler:', event.message);
    });

    function appendLog(msg, type = 'info') {
        let wasmLogs = document.getElementById("wasm_logs");

        // Create a span for the prefix (log level)
        let prefix = document.createElement('span');
        let prefixText = type.toUpperCase() + ": ";
        prefix.textContent = prefixText;

        // Apply color to the prefix based on the log type
        switch (type) {
            case 'info':
                prefix.style.color = 'blue';
                break;
            case 'debug':
                prefix.style.color = 'gray';
                break;
            case 'error':
                prefix.style.color = 'red';
                break;
            case 'warn':
                prefix.style.color = 'orange';
                break;
            default:
                prefix.style.color = 'black'; // Default color for prefix
        }

        // Create a text node for the actual log message
        let message = document.createTextNode(msg + "\n");

        // Append both the prefix and message to the logs container
        wasmLogs.appendChild(prefix);
        wasmLogs.appendChild(message);
    }

    // Expose appendLog globally
    window.appendLog = appendLog;

    function connectToNode() {
        if (window.startNode && typeof window.startNode === 'function') {
            const error = window.startNode(bootstrapAddresses);
            if (error) {
                console.error('Error starting node:', error);
                isConnected.set(false); // Update isConnected to false if startNode returns an error
            } else {
                isConnected.set(true);
            }
        } else {
            console.error('startNode method not available');
            isConnected.set(false); // Update isConnected to false if startNode method is not available
        }
    }

    function stopNode() {
        if (window.stopNode && typeof window.stopNode === 'function') {
            window.stopNode();
            isConnected.set(false);
            isStarted.set(false);
            peerID = null
            networkHead = null
            notification = null
            connectedPeers = null
            syncer = null
        } else {
            console.error('stopNode method not available');
        }
    }

    function clearDatabase() {
        let indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
        let request = indexedDB.deleteDatabase("celestia");

        request.onerror = (e) => createNotification("error", "Error deleting database.")
        request.onblocked = (e) => createNotification("error", "Couldn't delete database due to the operation being blocked.")
        request.onsuccess = (e) => createNotification("success", "Database deleted successfully.")
    }

    function createNotification(type, message) {
        notification = { type, message }
        setTimeout(closeNotification, 5000)
    }

    function closeNotification() {
        notification = null
    }

    function startedNode() {
        isStarted.set(true);
    }
    // Expose the startedNode function globally
    window.startedNode = startedNode;

    // Function to set and display the Peer ID
    function setPeerID(newPeerID) {
        peerID = newPeerID;
    }
    window.setPeerID = setPeerID;

    function setNetworkHead(nh) {
        networkHead = JSON.parse(nh)
    }
    window.setNetworkHead = setNetworkHead
    function nodeStartFailure() {
        isConnected.set(false);
        isStarted.set(false);
    }
    window.nodeStartFailure = nodeStartFailure;

    function setConnectedPeers(peers) {
        connectedPeers = peers.sort()
    }
    window.setConnectedPeers = setConnectedPeers

    function syncerInfo(si) {
        syncer = JSON.parse(si)
    }
    window.syncerInfo = syncerInfo

    onMount(async () => {
        if (!window.Go) {
            console.error('Go wasm_exec.jsnode is not loaded');
            return;
        }
        const go = new window.Go();

        let celestiaWasmModule;
        try {
            const wasmResponse = await fetch('celestia.wasm');
            celestiaWasmModule = await WebAssembly.instantiateStreaming(wasmResponse, go.importObject);
            go.run(celestiaWasmModule.instance);
            isModuleLoaded.set(true); // Set true when module is loaded
        } catch (err) {
            console.error('Failed to load celestia.wasm:', err);
            return;
        }

        // Fetch bootstrap peers when the page is loaded and fill them into the bootstrapper addresses.
        try {

            // Local demo requires the following.
            const bootstrapperHost = window.env?.PUBLIC_BOOTSTRAPER_HOST || 'https://lightray.eiger.co'
            const response = await fetch(`${bootstrapperHost}/bootstrap-peers`);

            // Production demo requires following.
            // const response = await fetch('/bootstrap-peers');

            if (response.ok) {
                const data = await response.json();
                bootstrapAddresses = Object.values(data.addrs).join('\n');
            } else {
                console.error('Failed to fetch peers:', response.statusText);
            }
        } catch (error) {
            console.error('Error fetching peers:', error);
        }
    });
</script>

<main>
    {#if notification }
    <div transition:fade={{ delay: 250, duration: 1000 }} class="fixed right-10 top-10 flex items-center w-full max-w-xs p-4 mb-4 text-gray-500 bg-white rounded-lg shadow-lg" role="alert">
        {#if notification.type === 'success'}
            <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-green-500 bg-green-100 rounded-lg dark:bg-green-800 dark:text-green-200">
                <svg class="w-5 h-5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z"/>
                </svg>
                <span class="sr-only">Check icon</span>
            </div>
        {:else if notification.type === 'warning'}
            <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-orange-500 bg-orange-100 rounded-lg dark:bg-orange-700 dark:text-orange-200">
                <svg class="w-5 h-5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5ZM10 15a1 1 0 1 1 0-2 1 1 0 0 1 0 2Zm1-4a1 1 0 0 1-2 0V6a1 1 0 0 1 2 0v5Z"/>
                </svg>
                <span class="sr-only">Warning icon</span>
            </div>
        {:else if notification.type === 'error'}
            <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-red-500 bg-red-100 rounded-lg dark:bg-red-800 dark:text-red-200">
                <svg class="w-5 h-5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 11.793a1 1 0 1 1-1.414 1.414L10 11.414l-2.293 2.293a1 1 0 0 1-1.414-1.414L8.586 10 6.293 7.707a1 1 0 0 1 1.414-1.414L10 8.586l2.293-2.293a1 1 0 0 1 1.414 1.414L11.414 10l2.293 2.293Z"/>
                </svg>
                <span class="sr-only">Error icon</span>
            </div>
        {/if}
        <div class="ms-3 text-sm font-normal">{notification.message}</div>
        <button
                class="ms-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex items-center justify-center h-8 w-8"
                type="button" aria-label="Close" on:click={closeNotification}>
            <span class="sr-only">Close</span>
            <svg class="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
            </svg>
        </button>
    </div>
    {/if}
    <div class="container mx-auto p-8">
        <h1 class="text-3xl font-bold mb-6">LightRay - Celestia Go Wasm Light Node</h1>
        <p class="text-lg mb-6">LightRay enables you to:</p>
        <ul class="list-disc pl-6 mb-6">
            <li>Start and stop the node</li>
            <li>Change bootstrap addresses as needed</li>
            <li>Connect to peers and download headers</li>
        </ul>
        <p class="mb-6">To connect to the Celestia network, secure webtransport addresses are required. Please note that the Celestia Wasm Node is compatible only with Google Chrome.</p>
        <p class="mb-6">For detailed logging information, please refer to the console logs.</p>

        <div class="mb-6">
            {#if $isConnected}
                <button class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                        on:click="{stopNode}">Stop
                </button>
            {:else}
                <button
                        class:bg-gray-500={(!$isModuleLoaded)}
                        class:hover:bg-gray-700={(!$isModuleLoaded)}
                        class:bg-blue-500={($isModuleLoaded)}
                        class:hover:bg-blue-700={($isModuleLoaded)}
                        class="text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                        on:click="{connectToNode}" disabled={!$isModuleLoaded}>
                    {#if $isModuleLoaded}
                        Connect
                    {:else}
                        {#if !$isConnected}
                            <span style="color: white;">Please wait while wasm node is being downloaded...</span>
                        {/if}
                    {/if}
                </button>
            {/if}
            <button on:click="{clearDatabase}" disabled={$isConnected} class="text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline bg-gray-800 hover:bg-gray-700 disabled:opacity-25">
                <span style="color: white;">Clear database</span>
            </button>
        </div>

        <div class="bg-white  pt-6 mt-2">
            <h2 class="text-xl font-bold mb-4">Bootstrap Addresses</h2>
            <textarea class="block p-2.5 w-full text-sm rounded-lg border border-gray-300" rows="10" bind:value={bootstrapAddresses}/>
        </div>


        {#if peerID || syncer || networkHead || connectedPeers}
            <div class="bg-white pt-6">
                <h2 class="text-xl font-bold mb-4">Status</h2>
                <ul>
                    {#if peerID}
                        <li><strong>PeerId:</strong> {peerID}</li>
                    {/if}
                    {#if syncer}
                        <li><strong>Synchronizing headers:</strong> {syncer.height || '0'}/{syncer.to_height || '0'}</li>
                    {/if}
                    {#if networkHead}
                        <li>
                            <strong>Latest block:</strong>
                            <ul>
                                <li class="ml-5"><strong>Height:</strong> {networkHead?.header?.height || ''}</li>
                                <li class="ml-5"><strong>Hash:</strong> {networkHead?.commit?.block_id?.hash || ''}</li>
                                <li class="ml-5"><strong>Data square size:</strong> {networkHead?.dah?.row_roots?.length || ''}x{networkHead?.dah?.column_roots?.length || ''} shares</li>
                            </ul>
                        </li>
                    {/if}
                    {#if connectedPeers}
                        <li>
                            <strong>Peers:</strong>
                            <ul>
                                {#each connectedPeers as peer}
                                <li class="ml-5">{peer}</li>
                                {/each}
                            </ul>
                        </li>
                    {/if}
                </ul>
            </div>
        {/if}
        <div class="bg-white pt-6">
            <h2 class="text-xl font-bold mb-4">Runtime Logs</h2>
            <pre id="wasm_logs" class="text-sm text-gray-700 overflow-auto" style="height: 300px; white-space: pre-wrap;"></pre>
        </div>
    </div>

</main>

<style>
    /* Add your CSS styles here */
</style>
