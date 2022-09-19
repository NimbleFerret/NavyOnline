import * as dotenv from "dotenv";
dotenv.config();

import { HardhatUserConfig } from "hardhat/config";
import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@nomiclabs/hardhat-etherscan";
import "@cronos-labs/hardhat-cronoscan";

const myPrivateKey: string = <string>process.env.PRIVATE_KEY;

task("accounts", "Prints the list of accounts", async (args, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

const config: HardhatUserConfig = {
    networks: {
        hardhat: {},
        ganache: {
            url: "HTTP://127.0.0.1:7545",
            accounts: [myPrivateKey],
        },
        cronosTestnet: {
            url: "https://evm-t3.cronos.org",
            chainId: 338,
            accounts: [myPrivateKey],
            gasPrice: 5000000000000,
        },
        cronos: {
            url: "https://evm.cronos.org/",
            chainId: 25,
            accounts: [myPrivateKey],
            gasPrice: 5000000000000,
        },
    },
    etherscan: {
        apiKey: {
            cronosTestnet: "",
            cronos: "",
        },
    },
    solidity: {
        version: "0.8.9",
        settings: {
            optimizer: {
                enabled: true,
                runs: 1000,
            },
        },
    }
};

export default config;