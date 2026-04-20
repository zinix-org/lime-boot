use regex::Regex;
use std::{
    fs::{OpenOptions, read_to_string},
    io::{Seek, SeekFrom, Write},
};

fn main() {
    let stage2_location_regex =
        Regex::new(r#"0x([0-9a-f]+)\s+stage2_cluster"#).expect("failed to compile regex");
    let map_file = read_to_string("build/floppy/stage1.map")
        .expect("failed to read `build/floppy/stage1.map`");

    let captures = stage2_location_regex
        .captures(&map_file)
        .expect("failed to pattern match map file");

    let cluster_address = captures
        .get(1)
        .expect("could not find `stage2_cluster` in map file");

    let cluster_address = u32::from_str_radix(&cluster_address.as_str(), 16)
        .expect("failed to parse cluster address as u32")
        - 0x7C00;

    println!("Found stage 2 cluster symbol at 0x{:x}", cluster_address);

    let mut img_file = OpenOptions::new()
        .read(true)
        .write(true)
        .open("build/floppy/stage1.img")
        .expect("failed to open floppy image file");

    img_file
        .seek(SeekFrom::Start(cluster_address as u64))
        .expect("failed to seek in bootsector file");

    let mut cluster = None;

    let fat_fs = fatfs::FileSystem::new(&img_file, fatfs::FsOptions::new()).unwrap();
    let root_dir = fat_fs.root_dir();
    for entry in root_dir.iter() {
        let entry = entry.unwrap();
    }

    img_file
        .write_all(&cluster.to_le_bytes())
        .expect("failed to write cluster number to bootsector");
}
