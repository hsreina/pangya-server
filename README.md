# Pangya-server
Welcome to pangya-server an emulation server for Pangya FreshUp.
The server is as always, an experiment on trying to code strange things. And hope someone will try to work on it instead of begging for release.

![Alt text](https://cloud.githubusercontent.com/assets/7342613/12693090/612aed5e-c6cf-11e5-9650-fbfa190746f4.png "Optional title")

# What is working?
    -You can login and select your 1st character and go to training
    -Create a chatroom walk and talk in it.
    -Create a game and set it up

# How to compile?
I created the project with Delphi XE8 professional, you should be able to open the project with the same version or above and compile it.
For Linux build, you'll need to use Delphi 10.2 Enterprise.


# External files
To run the server, you should provide extracted Iff files from the original US game into the directory ./data/pangya_gb.iff/
The structure are based on the latest Pangya US version.

# Pangya Crypt library
In the project files, you'll see references to a library "pang.dll"

"pang.dll" is a library used in some of my projects and will not be shared in this project. It will not be shared with the source code but maybe someone will can create it for you. Or maybe you'll create it for yourself.

You can found sample here
https://github.com/hsreina/pang.dll-sample

- The BCC32 version is the one we use on this server.

To make it work with your project, "pangya.dll" must share some functions the server will be able to understand.
  - pangya_client_decrypt
  - pangya_server_encrypt
  - pangya_client_encrypt
  - pangya_server_decrypt (not used but must be present)
  - deserialize
  - pangya_free (used to free buffout pointer allocated by the library)

defined as:

    #define DLLEXPORT EXTERN_C __declspec(dllexport)
    
    DLLEXPORT int pangya_client_decrypt(char *buffin, int size, char **buffout, int *buffoutSize, char key);
    DLLEXPORT int pangya_server_encrypt(char *buffin, int size, char **buffout, int *buffoutSize, char key);
    DLLEXPORT int pangya_client_encrypt(char *buffin, int size, char **buffout, int *buffoutSize, char key, char packetid);
	DLLEXPORT int pangya_server_decrypt(char *buffin, int size, char **buffout, int *buffoutSize, char key);
    DLLEXPORT UInt32 pangya_deserialize(UInt32 deserialize);
	DLLEXPORT void pangya_free(char **buffout);

"pangya_client_decrypt" must accept the full packet send by the client as data and must return the decrypted packet starting with the Id of the packet.

"pangya_server_encrypt" must accept the decrypted packet as data starting with the Id of the packet.

"pangya_client_encrypt" must accept the decrypted packet as data starting with the Id of the packet.

"pangya_server_decrypt" this function is not used by the server it must be present but its content can be empty

If you need more details about dll format, you still can send an e-mail to bugreport@shadosoft-tm.com

# Pull Requests
Commits should contain description for what you are modifying or working on. 

More rules will be added later.

