# LightRay: Celestia Light Node for Web Browsers

LightRay represents a pioneering advancement in blockchain technology, introducing a web browser-compatible version of the Celestia light node through WebAssembly. This innovation includes a web service that effortlessly hosts the Celestia node, granting users the convenience of starting and stopping a Celestia light node directly within their browser interface.

## Connectivity and Compatibility

To engage with the Celestia network, users must utilize secure WebTransport addresses. It is important to highlight that the LightRay Wasm Node is specifically designed for Google Chrome compatibility, ensuring a seamless experience for users of this browser.

## Node Functionality and Limitations

In adapting to the unique environment of web browsers, LightRay focuses on light node functionalities, acknowledging the inherent limitations of browser-based operations. Notably, the browser context restricts the ability to accept incoming connections, leading to the omission of several services including gateway and RPC functionalities, admin state management, blob services, as well as metrics and tracing capabilities.

Despite these adjustments, LightRay maintains crucial functionalities such as header synchronization, Data Availability Sampling (DAS), and a Fraud detection service, demonstrating its commitment to delivering essential blockchain services within the constraints of a web browser platform.

# Installation Instructions

To get started with a manual installation, follow these steps:

## Manual installation
1. Clone the repository to your local machine and navigate to the directory: `git clone git@github.com:eigerco/lightray.git && cd lightray`.
2. Build the Celestia wasm node: `make build-celestia-wasm`
3. Start the development server: `npm start dev`. After starting the server, you can access the web interface at: http://localhost:8080
4. To run a Celestia light node locally, refer to the official Celestia documentation. You can find instructions for running a light node [here](https://docs.celestia.org/nodes/light-node) and for running as a Docker image [here](https://docs.celestia.org/nodes/docker-images). For obtaining the authentication token, visit [this page](https://docs.celestia.org/developers/node-tutorial#auth-token).
5. Start the bootstrapper service by setting the `CELESTIA_NODE_AUTH_TOKEN=<auth_token> CELESTIA_NODE_IP_ADDR=<node_address> make run-bootstrapper` environment variables. The [bootstrapper](#bootstrapper) service is necessary for the operation of the Celestia wasm node.
6. Navigate back to the development server web interface and start the node!

## Web
The web service functions as the host and instantiation point for the LightRay node. 
It leverages IndexedDB for persistent data storage and key management, ensuring durability and security for both the data store and the keystore components.

### UI
Is a minimal UI allowing to start a node and connect to the network, stop the node and clear the database cache.
The UI is written in svelte.
- *Clear Database* button - Purges all the data in the database, is active only while the node is in the stopped state
- *Connect* button - Starts a light node and connect to the network
- *Stop* button - Stops the node
- *Bootstrap Addresses* text field - allows to manually configure the bootstrap node addresses, each address should be on a new line. Or use the default address provided by the bootstrapper service. 
- *Runtime Logs* section - Provide minimal logging output such as Node started, Node stopped etc. For more detailed logging please refer to the console logs.
- *Status* section - Displays node information such as peer id, sync headers, latest block info and connected peers.

## Bootstrapper
Bootstrapper is a service that runs alongside our web application, 
it has a `/bootstrap-peers` endpoint that is being called when the web app is 
loaded and requests the bootstrap node addresses from celestia,
then the addresses are being passed down to the node when it is started.

# Demo
The LightRay web service can be accessed at https://lightray.eiger.co/.

# Contributors
LightRay was built in collaboration between [Celestia](https://celestia.org/) and [Eiger](https://www.eiger.co/).

[Celestia](https://celestia.org/) - Celestia is a modular data availability network that makes it easy for anyone to securely launch their own blockchain.

[Eiger](https://www.eiger.co/) - Provides high-value add engineering services to accelerate web3 mass adoption.

# LICENSE
LightRay is released under the Apache 2.0 License. See the [LICENSE](./LICENSE) file for more details.
