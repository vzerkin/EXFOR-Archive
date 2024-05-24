# EXFOR-Archive (2005-2024)
_by V.Zerkin, IAEA, 2000-2024_

### Content
- all EXFOR Entries compiled and officially exchanged by International Network of Nuclear Reaction Data Centres (NRDC) since 2005
- CSV index of Entries with EntryID, last data update, first author, first refererence, title, DOI, etc.
- scripts to restore EXFOR Master files retroactively, all history of an Entry, etc.


### Download

- Download current repository files using Web_browser: (1) click **[<> Code]**, (2) click **[Download ZIP]**.

- If you have installed **git**, you can download full repository using terminal command:
```
      git clone https://github.com/vzerkin/EXFOR-Archive.git
```

### Scripts
1. **`merge_entries.sh`** _merge Entries to a single EXFOR file: produce Master/Backup file, store selected Areas_
2. **`go2date.sh`** _go to selected date: rollback Git-state_
3. **`list_exfor_updates.sh`** _list EXFOR updates (backup files) according to current Git-state_
4. **`get_entry.sh`** _get EXFOR Entry versions as files with timestamps in the file names_
5. **`setdates2clone.sh`** _set timestamp to files cloned from GitHub_


### References
- V.Zerkin, NRDC-2023, [Distribution of whole EXFOR: versioning](https://www-nds.iaea.org/nrdc/nrdc_2023/present/zerkin2.pdf#page=7)
- V.Zerkin, NRDC-2024, [EXFOR offline distribution](https://nds.iaea.org/nrdc/nrdc_2024/present/zerkin2.pdf)

