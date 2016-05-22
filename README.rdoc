# tobak

tobak is a tool for backing up files which are distributed (redundantly) over several resources.

Most computer users today have to deal with their data being distributed among several devices, e.g. the PC they use at home, the laptop they use when traveling, an old PC they used a few years ago, their smartphone, the feature phone they used before, the tablet PC they use when sitting on the couch and surfing the internet, a media PC connected to their TV screen, possibly the PC they use at work (if there is data "belonging" to the user, and not only "his company's" data), an USB hard disc used for sporadic backups, another one for photos and videos, a dozen USB sticks used to move data form one device to the other, a SD card within the camera, a SD card full with photos to be moved to the picture collection (on the PC and on the USB hard disc), and so on.

Cloud services are a fine way to synchronize some of your data between these devices various devices. But they can be used only for parts of your data and you must but some effort in synchronizing the data stored locally on the devices with the data stored in the cloud.

You *could* store *all* of your data *only* in the cloud (*only* in the cloud, not locally on your devices, such that you don't have to care about device/cloud synchronization) given that
- you trust the cloud service provider's confidentiality sufficiently to copy all your personal data to the cloud,
- you trust the cloud service provider's reliability sufficiently to copy all your personal data to the cloud (they will very likely have a far better data redundancy and backup strategy than you can establish on your own, but what is the cloud service runs out of business?),
- the cloud service provides sufficient storage space for all you data,
- you have enough bandwidth to store and access all your data form the cloud and
- you always have access to the cloud (or have according "offline" mechanisms installed) when you need to access your data.

Some of these issues could be addressed by setting up a private cloud service (e.g. https://en.wikipedia.org/wiki/OwnCloud). Still, I don't want to store a lot of my data exclusively in the cloud, I prefer to have most of my data stored locally on some device I own and can access.

tobak is a tool for aggregating data from various resources (computers, smartphones, hard drives, usb sticks, sd cards, etc.) into one single large backup repository. This repository could be located e.g. on a large externel hard disc or on a NAS system. For each resource backed up in the repository and each backup session, a separate directory exists where all files form the resource can be found a the directory tree matching the resource's directory tree when running the backup. If two files with the same content are added to the backup repository, tobak uses hard links to present the file in different directory trees while allocation only once storage space for the file content. Files distributed redundantly over several resources can thus be aggregated efficiently on a single backup resource. Also, multiple backups of the same resource at diffent points in time can be stored in the repository very efficiently as only the changed files require additional storage space.

Note: tobak neither deals with confidentiality nor reliability of the backup repository (following the Unix DOTADIW principle). Take care to encrypt the device that holds your backup repository and to regularly copy the repository to a redundant medium.

---

The name tobak indicates that the command is used to add files *to* your *ba*c*k*up repository. Its not to honor smoking (see https://en.wikipedia.org/wiki/Health_effects_of_tobacco).

---

# License

Copyright (c) 2016  Thilo Fischer

This file is part of tobak.

tobak is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

tobak is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with tobak.  If not, see <http://www.gnu.org/licenses/>.
