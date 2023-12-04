<script>
    import { onMount } from 'svelte';
	import { writable } from 'svelte/store';

    let isConnected = writable(false);

    function connectToNode() {
        // Assuming goCelestia.Start is exposed to global scope
        if (window.goCelestia && typeof window.goCelestia.Start === 'function') {
            window.goCelestia.Start();
            isConnected.set(true);
        } else {
            console.error('goCelestia.Start method not available');
        }
    }

    function stopNode() {
        // Assuming goCelestia.Stop is exposed to global scope
        if (window.goCelestia && typeof window.goCelestia.Stop === 'function') {
            window.goCelestia.Stop();
            isConnected.set(stop);
        } else {
            console.error('goCelestia.Stop method not available');
        }
    }

    onMount(async () => {
        const go = new Go();
        const wasmModule = await WebAssembly.instantiateStreaming(fetch('main.wasm'), go.importObject);
        go.run(wasmModule.instance);

        const goCelestia = new Go();
        const celestiaWasmModule = await WebAssembly.instantiateStreaming(fetch('celestia.wasm'), go.importObject);
        go.run(celestiaWasmModule.instance);
    });
</script>

<main>
    <div class="container mx-auto p-8">
        <h1 class="text-3xl font-bold mb-6">Celestia Node Inspector Tool</h1>

        <div class="mb-6">
            <label for="nodeAddress" class="block text-gray-700 text-sm font-bold mb-2">Node Address:</label>
            <input type="text" id="nodeAddress" class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" placeholder="Enter node address">
        </div>

        <div class="mb-6">
            {#if $isConnected}
                <button class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" 
                        onclick="{stopNode}">Stop</button>
            {:else}
                <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" 
                        onclick="{connectToNode}">Connect</button>
            {/if}
            <button class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 ml-4 rounded focus:outline-none focus:shadow-outline" 
                    onclick="testConnectivity()">Test Connectivity</button>
        </div>

        <div class="bg-white shadow-md rounded p-6">
            <h2 class="text-xl font-bold mb-4">Logs</h2>
            <pre id="wasm_logs" class="text-sm text-gray-700 overflow-auto" style="height: 300px;"></pre>
        </div>
    </div>
</main>

<style>
    /* Add your CSS styles here */
</style>
