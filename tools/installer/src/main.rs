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

    let mut bin_file = OpenOptions::new()
        .read(true)
        .write(true)
        .open("build/floppy/stage1.bin")
        .expect("failed to open bootsector file");
    bin_file
        .seek(SeekFrom::Start(cluster_address as u64))
        .expect("failed to seek in bootsector file");

    let cluster: u16 = 0x1234;

    bin_file
        .write_all(&cluster.to_le_bytes())
        .expect("failed to write cluster number to bootsector");
}
