App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      console.log(web3.eth.accounts);
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
      console.log("not undefined");
      // console.log(web3.eth.accounts);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
      console.log("undefined");
      console.log(web3.eth.accounts);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("../IotSecurity.json", function(iotsecurity) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.IotSecurity = TruffleContract(iotsecurity);
      // Connect provider to interact with contract
      App.contracts.IotSecurity.setProvider(App.web3Provider);

      // App.listenForEvents();

      // Load account data
      web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        console.log("Im here");
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

      return App.render();
    });
  },

  render: function() {
    var securityInstance;
    var loader = $("#loader");
    var content = $("#content");

    return App.getDevice();
  },

  getDevice: function() {
    console.log("getUser");

    App.contracts.IotSecurity.deployed().then(function(instance) {
      return instance.user_arr_length();
    }).then(function(result) {
      console.log("result : " + result);
      console.log("JSON result : " + JSON.stringify(result));

      if(result>0){
        for (var i = 0; i < result; i++) {
          getUsersOneByOne(i);
        }
      }
      else{
        console.error("No Device Found");
      }

    }).catch(function(err) {
      console.error(err);
    });
  }

};

function getUsersOneByOne(i){
  console.log("getUsersOneByOne value : " + i);
  App.contracts.IotSecurity.deployed().then(function(instance) {
        return instance.user_arr(i);
      }).then(function(result) {
        $("option[value='NoDevices']").remove();
        $("#deviceDropDownMenu").append('<option value="' + result + '">' + result + '</option>')
        console.log("result : " + result);
        console.log("JSON result : " + JSON.stringify(result));
      }).catch(function(err) {
        // console.error(err);
      });
}

$(function() {
  $(window).load(function() {
    App.init();
  });
});