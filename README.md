# EXFOR-Archive (2005-2024)
_by V.Zerkin, IAEA, 2000-2024_

### Content
- Archive of all [EXFOR](EXFOR) Entries compiled and officially exchanged by International Network of Nuclear Reaction Data Centres (NRDC) since 2005
- [CSV](EXFOR/EXFOR.entry.csv) index of Entries with EntryID, last data update, first author, first refererence, title, DOI, etc.
- [Scripts](#Scripts) - Bash scripts to restore EXFOR Master files retroactively, all history of an Entry, etc.


### Data structure
```
    +---EXFOR/
        ¦   EXFOR.entry.csv    #Index of Entries                  
        ¦   *.sh               #Shell-scripts                     
        ¦   *.tto              #Terminal output from Shell-scripts
        +---1/                 #EXFOR Compilation Area:1
        ¦   +---100/
        ¦   ¦       10001.x4   #EXFOR ENTRY File
        ¦   ¦       ...
        ¦   ¦       10099.x4   #EXFOR ENTRY File
        ¦   +---101/
        ¦   ¦       10100.x4
        ¦   ¦       ...
        ¦   +---102/
        ¦   ...
        +---2/                 #EXFOR Compilation Area:2
        ¦   +---200/
        ¦   ...
        +---3/                 #EXFOR Compilation Area:3
        ¦...
        +---V/                 #EXFOR Compilation Area:V
```

### Download

- Download current repository files using Web_browser: (1) click ![alt text](img/code.png "Code"),
 (2) click ![alt text](img/download.png "Download")

- If you have installed **git**, you can download full repository using terminal command:
```shell
      git clone https://github.com/IAEA-NRDCNetwork/EXFOR-Archive.git
```

### Scripts
1. [`merge_entries.sh`](EXFOR/merge_entries.sh) _merge Entries to a single EXFOR file: 
 produce Master/Backup file, store selected Areas, see:_ [_tto_](EXFOR/merge_entries.tto)
2. [`go2date.sh`](EXFOR/go2date.sh) _go to selected date: rollback Git-state, see terminal output:_ [_tto_](EXFOR/go2date.tto)
3. [`list_exfor_updates.sh`](EXFOR/list_exfor_updates.sh) _list EXFOR updates (backup files) 
 according to current Git-state, see:_ [_tto_](EXFOR/list_exfor_updates.tto)
4. [`show_history_fast.sh`](EXFOR/show_history_fast.sh) _history of all EXFOR entries (all EXFOR updates):_
   [_tto_](EXFOR/show_history_fast.tto),
   _all_ [_updates_](EXFOR/history_updates.txt) _and_ [_summary_](EXFOR/area_updates.txt) by Areas
5. [`get_entry.sh`](EXFOR/get_entry.sh) _get EXFOR Entry versions as files with timestamps in the file names, see:_ [_tto_](EXFOR/get_entry.tto)
6. [`setdates2clone.sh`](EXFOR/setdates2clone.sh) _set timestamp to files cloned from GitHub, see:_ [_tto_](EXFOR/setdates2clone.tto)

> **Note.** 
> _Scripts 2-6 require **git** to be installed._

### References
- V.Zerkin, NRDC-2023, [Distribution of whole EXFOR: versioning](https://www-nds.iaea.org/nrdc/nrdc_2023/present/zerkin2.pdf#page=7)
- V.Zerkin, NRDC-2024, [EXFOR offline distribution](https://nds.iaea.org/nrdc/nrdc_2024/present/zerkin2.pdf)

