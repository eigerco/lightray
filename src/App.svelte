<script>
    import {onMount} from 'svelte';
    import {writable} from 'svelte/store';
    import {fade} from 'svelte/transition';

    let isConnected = writable(false);
    let isStarted = writable(false);
    let isModuleLoaded = writable(false); // State to track if the module is loaded
    let bootstrapAddresses = "";
    let peerID = '';
    let notification = null

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
        } else {
            console.error('stopNode method not available');
        }
    }

    function clearDatabase() {
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

    function nodeStartFailure() {
        isConnected.set(false);
        isStarted.set(false);
    }
    window.nodeStartFailure = nodeStartFailure;

    function cleanDatabase() {
        var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;

        // Open the database
        var request = indexedDB.open("celestia");

        // Handle success
        request.onsuccess = function(event) {
            var db = event.target.result;

            // Close the database connection first
            db.close();

            // Use the deleteDatabase method
            var deleteRequest = indexedDB.deleteDatabase("celestia");

            deleteRequest.onsuccess = function(event) {
                console.log("Database deleted successfully");
            };

            deleteRequest.onerror = function(event) {
                console.log("Error deleting database");
            };
        };

        // Handle errors
        request.onerror = function(event) {
            console.log("Error opening database");
        };
    }

    onMount(async () => {
        if (!window.Go) {
            console.error('Go wasm_exec.js is not loaded');
            return;
        }
        const go = new window.Go();

        let celestiaWasmModule;
        try {
            const wasmResponse = await fetch('celestia.wasm');
            celestiaWasmModule = await WebAssembly.instantiateStreaming(wasmResponse, go.importObject);
            isModuleLoaded.set(true); // Set true when module is loaded
        } catch (err) {
            console.error('Failed to load celestia.wasm:', err);
            return;
        }

        go.run(celestiaWasmModule.instance);

        // Fetch bootstrap peers when the page is loaded and fill them into the bootstrapper addresses.
        try {

            // Local demo requires following.
           // const response = await fetch('http://localhost:8096/bootstrap-peers');

            // Production demo requires following.
            const response = await fetch('/bootstrap-peers');

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
    <div transition:fade={{ delay: 250, duration: 1000 }} class="absolute right-10 top-10 flex items-center w-full max-w-xs p-4 mb-4 text-gray-500 bg-white rounded-lg shadow-lg" role="alert">
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
            <button on:click="{clearDatabase}" class="text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline bg-gray-800 hover:bg-gray-700">
                <span style="color: white;">Clear database</span>
            </button>
        </div>

        <div class="bg-white  pt-6 mt-2">
            <h2 class="text-xl font-bold mb-4">Bootstrap Addresses</h2>
            <textarea class="block p-2.5 w-full text-sm rounded-lg border border-gray-300" rows="10" bind:value={bootstrapAddresses}/>
        </div>

        <div class="bg-white pt-6">
            <h2 class="text-xl font-bold mb-4">Runtime Logs</h2>
            <pre id="wasm_logs" class="text-sm text-gray-700 overflow-auto" style="height: 300px; white-space: pre-wrap;"></pre>
        </div>
    </div>

</main>

<style>
    /* Add your CSS styles here */
</style>
