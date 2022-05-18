#!/usr/bin/env bash

## update with correct box folder and project

## If necessary, mount wharf
#sshfs -o defer_permissions vincent-sens2021600@bianca-sftp.uppmax.uu.se:vincent-sens2021600 ~/wharf_mnt

## Rsync wharf results with box folder
rsync -harv --exclude '*.bam' /Users/vinva957/wharf_mnt/Results /Users/vinva957/library/CloudStorage/Box-Box/SMS_5975 --delete

## Rsync only the figures to the github controlled folder
rsync -harv --prune-empty-dirs --include "*/" --include="*.pdf" --include=".png" --include="*.svg" --exclude="*" /Users/vinva957/wharf_mnt/Results /Users/vinva957/Desktop/NBIS/Projects/project_5975/SMS-5975-21-mut_bc --delete
