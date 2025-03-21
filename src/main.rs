use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::io::{self, BufRead, Write};
use termcolor::{Color, ColorChoice, ColorSpec, StandardStream, WriteColor};

lazy_static! {
    static ref ASN_MAP: HashMap<&'static str, &'static str> = {
        let mut m = HashMap::new();
        m.insert("59.43", "AS4809 电信CN2  [优质线路]");
        m.insert("202.97", "AS4134 电信163  [普通线路]");
        m.insert("218.105", "AS9929 联通9929 [优质线路]");
        m.insert("210.51", "AS9929 联通9929 [优质线路]");
        m.insert("219.158", "AS4837 联通4837 [普通线路]");
        m.insert("223.120.19", "AS58807 移动CMIN2[优质线路]");
        m.insert("223.120.17", "AS58807 移动CMIN2[优质线路]");
        m.insert("223.120.16", "AS58807 移动CMIN2[优质线路]");
        m.insert("223.118", "AS58453 移动CMI  [普通线路]");
        m.insert("223.119", "AS58453 移动CMI  [普通线路]");
        m.insert("223.120", "AS58453 移动CMI  [普通线路]");
        m.insert("223.121", "AS58453 移动CMI  [普通线路]");
        m
    };
    
    static ref IP_REGEX: Regex = Regex::new(r"(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})").unwrap();
}

// Get ASN information for an IP address
fn get_asn(ip: &str) -> Option<&'static str> {
    for (prefix, asn_info) in ASN_MAP.iter() {
        if ip.starts_with(prefix) {
            return Some(asn_info);
        }
    }
    None
}

// Write colored ASN text to stdout
fn write_colored_asn(asn_info: &str, stdout: &mut StandardStream) -> io::Result<()> {
    let parts: Vec<&str> = asn_info.split_whitespace().collect();
    let asn_code = parts.get(0).unwrap_or(&"");
    let asn_name = parts.get(1).unwrap_or(&"");
    
    // Set color based on ASN
    let color = match *asn_code {
        "AS9929" => Color::Yellow,
        "AS4809" => Color::Magenta,
        "AS58807" => Color::Blue,
        _ => Color::White,
    };
    
    // Write the colored text
    stdout.set_color(ColorSpec::new().set_fg(Some(color)).set_bold(true))?;
    write!(stdout, "[{}]", asn_name)?;
    stdout.reset()?;
    
    Ok(())
}

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut stdout = StandardStream::stdout(ColorChoice::Auto);
    
    for line in stdin.lock().lines() {
        if let Ok(line) = line {
            let mut last_index = 0;
            
            for ip_match in IP_REGEX.captures_iter(&line) {
                let ip = &ip_match[1];
                let match_start = ip_match.get(0).unwrap().start();
                let match_end = ip_match.get(0).unwrap().end();
                
                // Write text before the IP
                write!(stdout, "{}", &line[last_index..match_start])?;
                
                // Write the IP
                write!(stdout, "{}", ip)?;
                
                // Write colored ASN if available
                if let Some(asn_info) = get_asn(ip) {
                    write!(stdout, " ")?;
                    write_colored_asn(asn_info, &mut stdout)?;
                }
                
                last_index = match_end;
            }
            
            // Write remaining text after the last IP
            writeln!(stdout, "{}", &line[last_index..])?;
        }
    }
    
    Ok(())
} 