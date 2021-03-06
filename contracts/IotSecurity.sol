pragma solidity ^0.4.24;

contract IotSecurity {
    
	string public readData;
    bool access;
    address [] public user_arr;
    uint public user_arr_length = 0;
    string public user_permission ="Not Available";

    struct deviceUserInfo {
        address user;
        string data;
        string permission;
    }
   
    struct user_info {
        address device;
        string permission;
    }
    
    struct user {
        user_info[] users_devices;
    }
    
    struct device {
        address owner;
        deviceUserInfo[] DeviceInfo;
    }
    
    event e_Permission (string permission);
    
    mapping(address => device) devices;
    
    mapping(address => user) users;
    
    //check the owner of the device - there can be only one owner per device
    modifier owner(address checkDevice){
        address checkOwner;
        checkOwner = devices[checkDevice].owner;
        delete user_arr;
        require(msg.sender == checkOwner);
        _;
    }
    
    //check if the device has an owner or a new device ( new device has the address of 0x00000000000000000000)
    modifier firstUser(address dAddr){
        require(devices[dAddr].owner == 0x00000000000000000000);
        _;
    }
    
    //owner can add users to his owned devices
    function addUsersToDevice (string permission, address deviceAddress, address userAddress) public owner(deviceAddress){
        deviceUserInfo memory obj = deviceUserInfo({
            user: userAddress,
            data: "null",
            permission: permission
        });
        devices[deviceAddress].DeviceInfo.push(obj);

        user_info memory obj2 = user_info({
            device: deviceAddress,
            permission: permission
        });

        users[userAddress].users_devices.push(obj2);
    }

    //owner can check all the users added to the device he owns
    function getUsersFromDevice (address devAddress) public owner(devAddress) returns (address[]){
        delete user_arr;
        user_arr_length = 0;
        for (uint i = 0 ; i < devices[devAddress].DeviceInfo.length ; i++){
            user_arr.push(devices[devAddress].DeviceInfo[i].user);
            user_arr_length = user_arr.length;
        }
        return user_arr;
    }
    
    // //owner can check permission for a given user and device
    function getUserPermissionsForaDevice (address devAddress, address userAddress) public returns (string){
        for (uint i = 0 ; i < devices[devAddress].DeviceInfo.length ; i++){
            if (devices[devAddress].DeviceInfo[i].user == userAddress){
                user_permission = devices[devAddress].DeviceInfo[i].permission;
                return user_permission;
            }
        }
    }
   
    
    function changePermission (address devAddress, address userAddress, string permission) public {
        for (uint i = 0 ; i < devices[devAddress].DeviceInfo.length ; i++){
            if (devices[devAddress].DeviceInfo[i].user == userAddress){
                devices[devAddress].DeviceInfo[i].permission = permission;
                emit e_Permission(permission);
                break;
            }
        }
    }
    

    //check all the available devices for a given account
    function getUsersDevices() public returns (address[]){
        delete user_arr;
        user_arr_length = 0;
        if(users[msg.sender].users_devices.length>0){
            for (uint i = 0; i < users[msg.sender].users_devices.length; i++){
                user_arr.push(users[msg.sender].users_devices[i].device);
                user_arr_length = user_arr.length;
            }
        return user_arr;
        }
    }

    //check all the  devices owned by the user
    function getOwnerDevices() public returns (address[]){
        delete user_arr;
        for (uint i = 0; i < users[msg.sender].users_devices.length; i++){
            address tempDaddress = users[msg.sender].users_devices[i].device;
            if(msg.sender == devices[tempDaddress].owner){
                user_arr.push(tempDaddress);
            }
        }
        return user_arr;
    }
    
    //add the owner of the device 
    function addOwner(address newDevice) public firstUser(newDevice){
        devices[newDevice].owner = msg.sender;
        deviceUserInfo memory obj = deviceUserInfo({
            user: msg.sender,
            data: "null",
            permission: "Read/Write"
        });
        devices[newDevice].DeviceInfo.push(obj);

        user_info memory obj2 = user_info({
            device: newDevice,
            permission: "Read/Write"
        });

        users[msg.sender].users_devices.push(obj2);
    }
    
    //view the owner of the device
    function viewOwner(address deviceAddr) public view returns (address){
        return (devices[deviceAddr].owner);
    }
	
	//send data to a device
	function sendData(address deviceAddr, string data){
        for (uint i = 0 ; i < devices[deviceAddr].DeviceInfo.length ; i++){
            address devUser = devices[deviceAddr].DeviceInfo[i].user;
            string memory permission = devices[deviceAddr].DeviceInfo[i].permission;
            if(devUser == msg.sender && (keccak256(permission) == keccak256("write") || keccak256(permission) == keccak256("all"))){
                devices[deviceAddr].DeviceInfo[i].data = data;
                break;
            }
        }
    }
    
	// get data from a device
    function getData(address deviceAddr, address user) returns (string){
        string memory permission;
        for (uint i = 0 ; i < devices[deviceAddr].DeviceInfo.length ; i++){
           if(devices[deviceAddr].DeviceInfo[i].user == msg.sender ){
                permission = devices[deviceAddr].DeviceInfo[i].permission;
                break;
            } 
        }
        for (uint j = 0 ; j < devices[deviceAddr].DeviceInfo.length ; j++){
            //address memory devUser = devices[deviceAddr].DeviceInfo[i].user;
            
            if(devices[deviceAddr].DeviceInfo[j].user == user && (keccak256(permission) == keccak256("read") || keccak256(permission) == keccak256("all"))){
                readData = devices[deviceAddr].DeviceInfo[j].data;
                break;
            } 
        }
        return readData;
    }
    
	//verify a transaction
    function verifyTransaction(string reqPermission, address deviceAddr, address userAddr) public{
        
        for(uint i = 0; i<devices[deviceAddr].DeviceInfo.length; i++){

            string memory permission = devices[deviceAddr].DeviceInfo[i].permission;
        
            if (  keccak256(permission) == keccak256(reqPermission) ){
                
               access = true;
                break;
            }
            access = false;
        }   
    }

    
    
}