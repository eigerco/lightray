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

1. **Clone the repository**:  
   Run the following command to clone the repository to your local machine and navigate to the project directory:
   ```bash
   git clone git@github.com:eigerco/lightray.git && cd lightray
   ```

2. **Build and start the application**:  
   Move into the Docker directory and execute the Docker Compose command to build and start the application:
   ```bash
   cd docker && docker-compose -f docker-compose.yaml up --build
   ```

## Running Locally with Bootstrapper Using Docker

1. **Clone the repository**:  
   Clone the repository to your local machine and navigate to the project directory:
   ```bash
   git clone git@github.com:eigerco/lightray.git && cd lightray
   ```

2. **Set up your public IP address**:  
   Ensure that your public IP address can accept TCP and UDP connections on port `6060`. This requires setting up port forwarding and creating appropriate firewall rules.

3. **Configure the bootstrapper**:  
   Open the `./docker/bootstrapper-config.json` file and replace `<your-public-ip>` with your actual public IP address.

4. **Build and start the application with Bootstrapper**:  
   Navigate to the Docker directory and run Docker Compose, using the `docker-compose-with-bootstrapper.yaml` file:
   ```bash
   cd docker && docker-compose -f docker-compose-with-bootstrapper.yaml up --build
   ```

## Web service
The web service functions as the host and instantiation point for the LightRay node. 
It leverages IndexedDB for persistent data storage and key management, ensuring durability and security for both the data store and the keystore components.

### User Interface

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
LightRay is the fruit of collaboration between [Celestia](https://celestia.org/) and [Eiger](https://www.eiger.co/).

## About [Eiger](https://www.eiger.co)

We are engineers. We contribute to various ecosystems by building low level implementations and core components. We are core contributors to Celestia because we believe in the modular stack and Celestia's data availability offering. Check out [Lumina](https://github.com/eigerco/lumina) our other light node in Rust.

Contact us at hello@eiger.co
Follow us on [X/Twitter](https://x.com/eiger_co)

# LICENSE
LightRay is made available under the Apache 2.0 License, reflecting our commitment to open-source collaboration and innovation. For detailed licensing information, refer to the [LICENSE](./LICENSE) file.
