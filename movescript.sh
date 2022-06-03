#!/usr/bin/env bash

## update with correct box folder and project

## If necessary, mount wharf
#sshfs -o defer_permissions vincent-sens2021600@bianca-sftp.uppmax.uu.se:vincent-sens2021600 ~/wharf_mnt

## Rsync wharf results with box folder
rsync -harv --exclude '*.bam' --exclude '*.bigWig' --exclude '*.mat.tab' --exclude '*.mat.gz' /Users/vinva957/wharf_mnt/Results /Users/vinva957/library/CloudStorage/Box-Box/SMS_5986 --delete

## Rsync only the figures to the github controlled folder
rsync -harv --prune-empty-dirs --include "*/" --include="*.pdf" --include="*.png" --include="*.svg" --include="*.csv" --include="*.html"  --include="*.xlsx" --exclude="*" /Users/vinva957/wharf_mnt/Results /Users/vinva957/Desktop/NBIS/Projects/SMS-5986-21-atac --delete
