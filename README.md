# SwiftParseTCC

![Help](https://raw.githubusercontent.com/slyd0g/SwiftParseTCC/main/example.png)

![Output](https://raw.githubusercontent.com/slyd0g/SwiftParseTCC/main/example2.png)

## Description

This tool leverages the research linked below to understand the contents of TCC.db. Uses "Full Disk Access" permissions to read contents of TCC.db and display in human-readable format. Can output as a pseudo table viewable in the terminal or as a text table which is viewed best in a text editor. 

## Usage
- Dump global TCC.db as a pseudo table
    - ```./SwiftParseTCC -p "/Library/Application Support/com.apple.TCC/TCC.db"```
- Dump user TCC.db as a text table (best viewed in a text editor)
    - ```./SwiftParseTCC -path "~/Library/Application Support/com.apple.TCC/TCC.db" -table```

## Note
The base64 encoded blobs are binary blobs that describe the code signing requirement. This is used to prevent spoofing/impersonation if another program uses the same bundle identifier. They can be decoded using the ```csreq``` binary as follows:
```
slyd0g@Justins-MBP ~ % echo "+t4MAAAAADAAAAABAAAABgAAAAIAAAASY29tLmFwcGxlLlRlcm1pbmFsAAAAAAAD" | base64 -d > lol.bin
slyd0g@Justins-MBP ~ % csreq -v -r lol.bin -t
identifier "com.apple.Terminal" and anchor apple
```

## References
- https://rainforest.engineering/2021-02-09-macos-tcc/
- https://stackoverflow.com/questions/52706542/how-to-get-csreq-of-macos-application-on-command-line/57259004#57259004