<script>
    import {onMount} from 'svelte';
    import {writable} from 'svelte/store';

    let isConnected = writable(false);
    let isModuleLoaded = writable(false); // State to track if the module is loaded
    let bootstrapAddresses = "";

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
            window.startNode();
            isConnected.set(true);
        } else {
            console.error('startNode method not available');
        }
    }

    function stopNode() {
        if (window.stopNode && typeof window.stopNode === 'function') {
            window.stopNode();
            isConnected.set(false);
        } else {
            console.error('stopNode method not available');
        }
    }

    function initNode() {
        if (window.initNode && typeof window.initNode === 'function') {
            window.initNode(bootstrapAddresses)
        }
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
    });
</script>

<main>
    <div class="container mx-auto p-8">
        <h1 class="text-3xl font-bold mb-6">Celestia Node Inspector Tool</h1>

        <div class="mb-6">
            <label for="nodeAddress" class="block text-gray-700 text-sm font-bold mb-2">Node Address:</label>
            <input type="text" id="nodeAddress"
                   class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                   placeholder="Enter node address">
        </div>

        <div class="mb-6">
            {#if $isConnected}
                <button class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                        on:click="{stopNode}">Stop
                </button>
            {:else}
            <button class:bg-gray-500={(!$isModuleLoaded)} class:hover:bg-gray-700={(!$isModuleLoaded)} class:bg-blue-500={($isModuleLoaded)} class:hover:bg-blue-700={($isModuleLoaded)} class="text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            on:click="{connectToNode}" disabled={!$isModuleLoaded}>
            {#if $isModuleLoaded}
                Connect
            {:else}
                Loading Module...
            {/if}
            </button>
            {/if}
            <button class="font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                    on:click="{initNode}" disabled={!$isModuleLoaded}>
                Init
            </button>
        </div>

        <div class="bg-white shadow-md rounded p-6">
            <h2 class="text-xl font-bold mb-4">Logs</h2>
            <pre id="wasm_logs" class="text-sm text-gray-700 overflow-auto" style="height: 300px;"></pre>
        </div>


        <div class="bg-white shadow-md rounded p-6 mt-2">
            <h2 class="text-xl font-bold mb-4">Bootstrap Addresses</h2>
            <textarea class="block p-2.5 w-full text-sm rounded-lg border border-gray-300" rows="10" bind:value={bootstrapAddresses}/>
        </div>

    </div>

</main>

<style>
    /* Add your CSS styles here */
</style>
