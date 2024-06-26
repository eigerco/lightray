# LightRay: Celestia Light Node for Web Browsers

LightRay introduces a significant enhancement within the Celestia ecosystem, enabling a browser-compatible version of the Celestia light node through WebAssembly. This development features a web service that facilitates easy hosting of the Celestia node, providing users with the capability to directly operate a Celestia light node from their web browser interface.

## Connectivity and Compatibility

To engage with the Celestia network, users must utilize secure WebTransport addresses. It is important to highlight that the LightRay Wasm Node is specifically designed for Google Chrome compatibility, ensuring a seamless experience for users of this browser.

## Node Functionality and Limitations

In adapting to the unique environment of web browsers, LightRay focuses on light node functionalities, acknowledging the inherent limitations of browser-based operations. Notably, the browser context restricts the ability to accept incoming connections, leading to the omission of several services including gateway and RPC functionalities, admin state management, blob services, as well as metrics and tracing capabilities.

Despite these adjustments, LightRay maintains crucial functionalities such as header synchronization, Data Availability Sampling (DAS), and a Fraud detection service, demonstrating its commitment to delivering essential blockchain services within the constraints of a web browser platform.

# Installation Instructions

To get started with a manual installation, follow these steps:

## Running Locally with Docker
1. Clone the repository to your local machine and navigate to the directory: `git clone git@github.com:eigerco/lightray.git && cd lightray`.
2. Move into the docker directory and execute docker-compose to build and start the application: `cd docker && docker-compose -f docker-compose.yaml up --build`

## Running Locally with Bootstrapper Using Docker
1. Clone the repository to your local machine and navigate to the directory: `git clone git@github.com:eigerco/lightray.git && cd lightray`.
2. Ensure that your public IP address can accept TCP and UDP connections on port `6060`. This requires port forwarding and creating firewall rules.
3. Open the `./docker/bootstrapper-config.json` file and replace `<your-public-ip>` with your actual public IP address.
4. Navigate to the docker directory and run docker-compose, this time utilizing the `docker-compose-with-bootstrapper.yaml` file: `cd docker && docker-compose -f docker-compose-with-bootstrapper.yaml up --build`

## Web
The web service functions as the host and instantiation point for the LightRay node. 
It leverages IndexedDB for persistent data storage and key management, ensuring durability and security for both the data store and the keystore components.

### UI

The UI offers a minimalistic interface for interacting with the LightRay node. It supports operations such as starting and stopping the node, connecting to the network, and clearing the database cache. Developed using Svelte, the UI features include:

- **Clear Database Button**: This button purges all data within the database.
- **Connect Button**: Initiates the light node and establishes a connection to the network, enabling participation in the network activities.
- **Stop Button**: Safely stops the node's operation, ensuring a graceful shutdown of activities.
- **Bootstrap Addresses Text Field**: Allows for manual configuration of bootstrap node addresses, each entered on a new line. Alternatively, the default address provided by the bootstrapper service can be used for convenience. Please note that only secure web transport bootstrappers are supported!
- **Runtime Logs Section**: Offers a minimalist logging view, presenting essential outputs like "Node started" and "Node stopped." For in-depth logging, users are directed to consult the console logs.
- **Status Section**: Displays critical node information including the peer ID, synchronization headers, latest block information, and details on connected peers for operational insight.

## Bootstrapper
The Bootstrapper service operates in conjunction with our web application, featuring a key endpoint, `/bootstrap-peers`, that interacts seamlessly with the Celestia network. Upon the web application's initialization, this endpoint is invoked to fetch the addresses of bootstrap nodes from Celestia. It is important to note that only secure WebTransport addresses are utilized to ensure the integrity and security of the communication. These secure addresses are subsequently supplied to the node at the commencement of its operation, facilitating its secure integration into the network.


# Demo
Experience the capabilities of the LightRay web service firsthand by visiting [https://lightray.eiger.co/](https://lightray.eiger.co/).

# Contributors
LightRay represents a collaborative effort between [Celestia](https://celestia.org/) and [Eiger](https://www.eiger.co/), uniting to innovate within the web3 space.

- **[Celestia](https://celestia.org/)**: A modular data availability (DA) network that securely scales with the number of users, making it easy for anyone to launch their own blockchain.
- **[Eiger](https://www.eiger.co/)**: Specializing in high-impact engineering services, Eiger is dedicated to accelerating the widespread adoption of web3 technologies.

# LICENSE
LightRay is made available under the Apache 2.0 License, reflecting our commitment to open-source collaboration and innovation. For detailed licensing information, refer to the [LICENSE](./LICENSE) file.
