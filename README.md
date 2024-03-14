# LightRay: Celestia Light Node for Web Browsers

LightRay represents a pioneering advancement in blockchain technology, introducing a web browser-compatible version of the Celestia light node through WebAssembly. This innovation includes a web service that effortlessly hosts the Celestia node, granting users the convenience of starting and stopping a Celestia light node directly within their browser interface.

## Connectivity and Compatibility

To engage with the Celestia network, users must utilize secure WebTransport addresses. It is important to highlight that the LightRay Wasm Node is specifically designed for Google Chrome compatibility, ensuring a seamless experience for users of this browser.

## Node Functionality and Limitations

In adapting to the unique environment of web browsers, LightRay focuses on light node functionalities, acknowledging the inherent limitations of browser-based operations. Notably, the browser context restricts the ability to accept incoming connections, leading to the omission of several services including gateway and RPC functionalities, admin state management, blob services, as well as metrics and tracing capabilities.

Despite these adjustments, LightRay maintains crucial functionalities such as header synchronization, Data Availability Sampling (DAS), and a Fraud detection service, demonstrating its commitment to delivering essential blockchain services within the constraints of a web browser platform.

# Installation Instructions

## Manual installation
1. Clone the repository on your local machine `git clone git@github.com:eigerco/lightray.git` and go to ./lightray dir.
2. Build the celestia wasm node `make build-celestia-wasm`
3. Run the npm dev server `npm start dev` now you should be able to access the web server on http://localhost:8080
4. To run a full celestia node locally follow the official instructions https://docs.celestia.org/nodes/full-storage-node or https://docs.celestia.org/nodes/docker-images if you want to run as a docker image. To get the auth token check this page https://docs.celestia.org/developers/node-tutorial#auth-token.
5. Run the bootstrapper - `CELESTIA_NODE_AUTH_TOKEN=<auth_token> CELESTIA_NODE_IP_ADDR=<node_address> make run-bootstrapper` - We also need to run another service called [bootstrapper](#bootstrapper) that points to the celestia full node.

## Web
The web service hosts and instantiates the LightRay node.
The data store and keystore are implemented using indexed db for persistence.

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
