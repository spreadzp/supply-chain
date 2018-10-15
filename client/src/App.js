import React, { Component } from "react";
import HolyContract from "./contracts/Holy.json";
import getWeb3 from "./utils/getWeb3";
import getContractInstance from "./utils/getContractInstance";

import "./App.css";

class App extends Component {
  state = {tokensOwn1: [], tokensOwn2: [], supply: [], storageValue: 0, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance by passing in web3 and the contract definition.
      const contract = await getContractInstance(web3, HolyContract);

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.log(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
   // await contract.methods.set(5).send({ from: accounts[0] });

    // Get the value from the contract to prove it worked.
    const tokensOwner1 = await contract.methods.tokensOfOwner(accounts[1]).call({ from: accounts[0] });
    const tokensOwner2 = await contract.methods.tokensOfOwner(accounts[2]).call({ from: accounts[0] });
    const supplyTokens = await contract.methods.cardSupply().call({ from: accounts[0] }); 

    // Update state with the result.
    this.setState({ tokensOwn1: tokensOwner1 });
    this.setState({ tokensOwn2: tokensOwner2 });
    this.setState({ supply: supplyTokens }); 
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>HOLY to Go!</h1> 
        <h2>Smart HOLY</h2> 
        <div> Tokens of player1: {this.state.tokensOwn1}</div>
        <div> Tokens of player2: {this.state.tokensOwn2}</div>
        <div>supply: {this.state.supply}</div> 
      </div>
    );
  }
}

export default App;
