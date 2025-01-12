---
title: Exporting photos from Google Photos and joining them into my local files
layout: post
---

## Motivation

I've used Google Photos to back up my photos for as long as it's existed, in fact, before, since I used its predecessor, Picasa, including its Web Albums feature.

Recently, I've become more interested in keeping and managing my files locally, partially because I've gotten close to the size limits of my Google account and do not want to pay for storage, but largely because I've been using a non-phone camera recently that does not automatically back up, and it's annoying to keep photos and albums in sync across two different locations.

I was left in an interesting predicament, where recently I've offloaded all my photos onto my computer (while leaving backup to Google Photos on), but also had many photos on Google Photos that were not backed up on my computer.

I used these steps to export and join my photos exported from Google Photos to my local collection.

I ran these steps on my Linux system, and I haven't checked, but I'm likely relying on some GNU-specific commands or options.

## Steps

1. Export photos from Google Photos. This can be done with Google Takeout. It gives you a couple options for export. I chose `.tar.gz` (tarball) export format because it allows bigger download sizes. This step will take the longest in terms of wall time depending on the size of your photos library.
1. Untar the archive with `tar xvzf <exported tarball>`.
1. Move all the exported photos into a single directory

    ```console
    $ find Takeout/Google\ Photos -type f -not -name "*.json" -exec mv -n -t google_photos {} +
    ```

    I'm excluding the `json` metadata included with the Google Photos export. Much of the information in it is already in the image exif tags. There's more in the `json` file that is Google Photos-specific, like the people identified in the photo, but I didn't think it was worth the time to process and figure out how to add this to an appropriate file attribute.

    The `-n` flag in the `mv` command says not to overwrite files. The way Google Photos exports will include a separate directory for each album for each album selected in the export process (I left them all selected). This means that there will be a lot of duplicate files. Adding the `-n` flag means that `mv` will not throw an error every time it tries to overwrite a file with its duplicate and will instead leave the duplicates in place.

    Once the `find` command is complete, the duplicates can be discarded.

1. Set difference the Google Photos export with captured photos and remove duplicates.

    Get list of files from both relevant directories. The command below shows how I did this for Google Photos.

    ```console
    $ find google_photos -type f -printf "%f\n" | sort > /tmp/google_photos.txt
    ```

    Delete the ones that appear in both files from the Google Photos exported collection.

    ```console
    $ comm -12 /tmp/google_photos.txt /tmp/internal.txt | xargs -I{} rm google_photos/{}
    ```

    `-12` suppresses columns 1 and 2 (the files that appear in only `file1` and `file2`), and thus only prints the files that appear in both (column 3). We then remove these from the Google Photos directory.
