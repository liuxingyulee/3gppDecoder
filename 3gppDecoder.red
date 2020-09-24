Red [
    Title: "3GPP DECODER"
    Author: "XuBin, KONGLONG"
    Contributor: "Mike Li"
    Date: 2020-09-24
    Version: 1.0.7
    purpose: "Convert UI from Chinese to English"
             "to employ Wireshark decode messages"
    Needs:   'View
]

default_config: make map! [
    wireshark-dir: "C:/Program Files/Wireshark"
    notepadpp-dir: "C:/Program Files (x86)/Notepad++"
    NAT: [
        #(LTE: [
            "lte-rrc.dl.ccch" "lte-rrc.dl.dcch" "lte-rrc.ul.ccch" "lte-rrc.ul.dcch" "s1ap" "x2ap"
            ])
        #(LTE-NB: [
            "nr-rrc.dl.ccch.nb" "nr-rrc.dl.dcch.nb" "nr-rrc.ul.ccch.nb" "nr-rrc.ul.dcch.nb" "s1ap" "x2ap"
            ])
        #(NR: [
            "nr-rrc.dl.ccch" "nr-rrc.dl.dcch" "nr-rrc.ul.ccch" "nr-rrc.ul.dcch" "xnap"
            ])
        ]
    ]

if error? try [
        config: load-json read %3gppDecoder.cfg
    ][
        config: default_config
    ]
print config
; print ? config/NAT/1/LTE
if error? try [
        ws_path: config/wireshark-dir
        text2pcap: rejoin[config/wireshark-dir "/text2pcap.exe"]
        tshark: rejoin[config/wireshark-dir "/tshark.exe"]
        notepad: rejoin[config/notepadpp-dir "/notepad++.exe"]
        wireshark: rejoin[config/wireshark-dir "/Wireshark.exe"]
    ][
        quit
    ]
; print ws_path
; print text2pcap
; print tshark
; print length? tshark

nats: make block! []
foreach p config/NAT [
    foreach [k v] p [
        append nats to-string k
    ]
]

default_nat: nats/2

if empty? nats [
    quit
]

selected-proto: ""

proc-hex-str: function [
    src-str [string!]
] [
    whitespace: charset reduce [space tab cr lf]
    hex-digits: charset ["0123456789" #"a" - #"f" #"A" - #"F"]

    replace/all src-str "," " "
    replace/all src-str "0x" " "
    replace/all src-str "0X" " "

    dst-str: ""
    hex-ind: 0
    str-len: 0
    clear dst-str

    parse src-str [some[
        some[whitespace] (hex-ind: 0)
        | [pos: hex-digits] (either hex-ind == 0 [
            append dst-str " 0"
            append dst-str pos/1
            str-len: str-len + 3
            hex-ind: 1
            ] [
                dst-str/(:str-len - 1): dst-str/:str-len
                dst-str/:str-len: pos/1
                hex-ind: 0
            ])
    ]]

    trim/head dst-str
    trim/tail dst-str
    dst-str
]

pre-proc-data: function [
    data [string!]
] [
    data: proc-hex-str data
    ; prep-area/text: data
    rejoin["0000 " data " 0000"]
]


wireshark-cmd-arg1: {"uat:user_dlts:\"User 0 (DLT=147)\",\"}
wireshark-cmd-arg2: {\",\"0\",\"\",\"0\",\"\""}

decode-handler: function [
    proto [string!]
    data [string!]
] [
    data-temp: copy data
    data-temp: pre-proc-data data-temp
    write %textdata_temp.txt data-temp
    text2pcap_cmd: rejoin[text2pcap " -l 147 textdata_temp.txt decode_temp.pcap"]
    ; print text2pcap_cmd
    call/wait text2pcap_cmd

    ;^(22)是"的转义，^(5c)是\的转义
    tshark_cmd: rejoin["^(22)" tshark "^(22) -V -o " wireshark-cmd-arg1 proto wireshark-cmd-arg2 " -r decode_temp.pcap"]
    print tshark_cmd
    write %decoded_result.txt "" 
    call/wait/output tshark_cmd %decoded_result.txt

    call/wait "del textdata_temp.txt"
    ; call/wait "del decode_temp.pcap"

    output-area/text: read %decoded_result.txt
]


open-wireshark-handler: function [
    proto [string!]
    data [string!]
] [
    data-temp: copy data
    data-temp: pre-proc-data data-temp
    write %textdata_temp.txt data-temp
    text2pcap_cmd: rejoin[text2pcap " -l 147 textdata_temp.txt decode_temp.pcap"]
    ; print text2pcap_cmd
    call/wait text2pcap_cmd

    ;^(22)是"的转义，^(5c)是\的转义
    wireshark_cmd: rejoin["^(22)" wireshark "^(22) -o " wireshark-cmd-arg1 proto wireshark-cmd-arg2 " -r decode_temp.pcap"]
    print wireshark_cmd
    call/shell wireshark_cmd

    call/wait "del textdata_temp.txt"
    ; call/wait "del decode_temp.pcap"
]

update-nat-proto: function [
    nat-str [string!]
] [
    foreach p config/NAT [
        foreach [k v] p [
            if nat-str = to-string k [
                proto-drop-down/text: v/1
                proto-drop-down/data: v
            ]
        ]
    ]
]

about-txt: {

Version:1.0.7
Source address of the 3GPP decoder:
https://github.com/konglinglong/3gppDecoder

3GPP decoder is a morden 3GPP decoder which can theoretically decode all protocols supported by Wireshark. And in the future, by modifying the configuration file, it can decode any new added in protocol message in the future.

Author: XuBin, KONGLONG
Contributor: Mike Li
}

main-window: layout [
    title "3GPP Decoder"
    text "Network Type" 80x25
    nat-drop-down: drop-down 60x25 data nats
    on-select [
        update-nat-proto face/text
        selected-proto: proto-drop-down/text
    ]
    text "Porotocol:" 60x25
    proto-drop-down: drop-down 125x25 data []
    on-select [
        selected-proto: face/text
    ]
    button "Decode" [
        if selected-proto <> "" [
            decode-handler selected-proto input-area/text
        ]
    ]
    button "Open it in Notepad++" [
        call rejoin[notepad " Decoded_result.txt"]
    ]
    button "Open it in Wireshark"[
        open-wireshark-handler selected-proto input-area/text
    ]
    button "Clear" [
        input-area/text: ""
        ; prep-area/text: ""
        output-area/text: ""
        clear input-area/text
        ; clear prep-area/text
        clear output-area/text
    ]
    return
    text "Paste hex codes here:"
    return
    input-area: area focus "" 800x60
    ; return
    ; text "码流预处理："
    ; return
    ;prep-area: area "" 800x60
    return
    text "Decoded codes："
    return
    output-area: area "" 800x400

    do [
        nat-drop-down/text: nats/1
        update-nat-proto nat-drop-down/text
        selected-proto: proto-drop-down/text
    ]
]

main-window/menu: [
    "File" [ "Quit" qt ]
    "Help" [ "About" ab ]
    ]
main-window/actors: make object! [
    on-menu: func [face [object!] event [event!]][ 
    switch event/picked [
        qt [quit]
        ab [
            view/flags [
                title "About"
                text 300x250 about-txt
                return
                OK-btn: button "OK" [unview]
                ] [modal popup]
            ]
            ] ] ]

view main-window

