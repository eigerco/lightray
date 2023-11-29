<script>
	import { onMount } from 'svelte';

	onMount(async () => {
		const go = new Go();
		const wasmModule = await WebAssembly.instantiateStreaming(fetch('main.wasm'), go.importObject);
		go.run(wasmModule.instance);
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
            <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" onclick="connectToNode()">Connect</button>
            <button class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 ml-4 rounded focus:outline-none focus:shadow-outline" onclick="testConnectivity()">Test Connectivity</button>
        </div>

		<div class="bg-white shadow-md rounded p-6">
			<h2 class="text-xl font-bold mb-4">Logs</h2>
			<pre id="wasm_logs" class="text-sm text-gray-700 overflow-auto" style="height: 300px;"></pre>
		</div>
    </div>
</main>

<style>

</style>