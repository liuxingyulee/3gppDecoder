3gppDecoder
=====

## Readme

This 3gppDecoder is based on Wireshark as codec. So it requires installed Wiresharek on your PC and configure the path of the Wireshark into the configuration file (_3gppDecoder.cfg_). 
 - This 3gppDecoder is able to decode the message/stack of GSM, CDMA, WCDMA, LTE, and 5G. The decoding cabability depends on the Wireshark.
 - You can configure the protocol/stack, i.e., RRC, NAS, etc., to support all types of message/stack which Wireshark supported.  
 - This 3gppDecoder supports the followings format hexcimal codes as inputs: 
   - continous codes, e.g., `1a2b3c432345`
   - codes devided by spaces ` `, e.g., `1a 2b 3c 43 23 45`
   - codes divided by comma `,`, e.g., `1a,2b,3c,43,23,45`
   - codes headed by `0x`, e.g., `0x1a 0x2b 0x3c 0x43 0x23 0x45`
   - mixed codes by all above fomats, e.g., `0x1a,2b ,3c 4323,0x45`
    
 
## User Interface Preview

<div align=center>
  <img src='https://github.com/liuxingyulee/3gppDecoder/blob/master/UI_image_3gppDecoder.png' alt='preview' />
</div>

## How to use the 3gppDecoder
###Download the 3gppDecoder packge
1. Download the zip package from [Release Page](https://github.com/liuxingyulee/3gppDecoder/releases) of the decoder.
2. Unzip the package, then configure the file of (_3gppDecoder.cfg_). 
   - set the path of the Wireshark in the file. (Note:please just use "\/" but not "\\\" in the path).
   - set the path of the Notepad++ application in the file. (Note:please just use "\/" but not "\\\" in the path). 
   - configure the protocol/stack, i.e., RRC, NAS, etc., into the file, as long as the Wireshark supports.
###Download the source code, compile it by [RED](https://static.red-lang.org/dl/auto/win/red-latest.exe)
1. After both source code and the .exe file of RED have been downloaded, run `D:\DevTools\red\red.exe 3gppDecoder.red` in a command line terminal to compile the source code.
2. When the compiling finishs, run `D:\DevTools\red\red.exe -r -t windows 3gppDecoder.red` in the terminal. (Note: Since there is some bug of RED, it needs direct path like the exmaple.Else, it may prompt `PROGRAM ERROR: Invalid encapsulated data`.)