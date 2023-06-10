package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"github.com/AspieSoft/go-regex/v4"
	"github.com/AspieSoft/goutil/v5"
	"github.com/alphadose/haxmap"
)

func main(){
	newFiles := haxmap.New[string, uint]()
	hasFiles := haxmap.New[string, uint]()
	lastNotify := uint(0)
	notifyDelay := uint(3000)

	scanDirList := []string{
		"Downloads",
		"Desktop",
		"Documents",
		"Pictures",
		"Videos",
		"Music",
	}


	homeDir, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	for _, arg := range os.Args[1:] {
		if dir := string(regex.Comp(`[^\w_-]+`).RepStr([]byte(arg), []byte{})); dir != "" {
			scanDirList = append(scanDirList, dir)
		}
	}


	// create quarantine directory if it does not exist
	if _, err := os.Stat("/VirusScan/quarantine"); err == nil || !strings.HasSuffix(err.Error(), "permission denied") {
		exec.Command(`sudo`, `mkdir`, `-p`, `/VirusScan/quarantine`, `&&`, `sudo`, `chmod`, `0664`, `/VirusScan`, `&&`, `sudo`, `chmod`, `2660`, `/VirusScan/quarantine`, `&&`, `sudo`, `chmod`, `-R`, `2660`, `/VirusScan/quarantine`).Run()
	}


	cmd := exec.Command(`find`, homeDir+"/.config", `-type`, `d`, `-name`, `*xtensions`)
	if stdout, err := cmd.StdoutPipe(); err == nil {
		go func(){
			for {
				b := make([]byte, 1024)
				_, err := stdout.Read(b)
				if err != nil {
					break
				}

				list := bytes.Split(b, []byte{'\n'})
				if len(list) == 0 {
					continue
				}
				if list[len(list)-1][0] == 0 {
					list = list[:len(list)-1]
				}
				
				for _, dir := range list {
					dir = regex.Comp(`[\r\n\t ]+`).RepStrRef(&dir, []byte{})
					if !bytes.Contains(dir, []byte("/tmp/")) {
						scanDirList = append(scanDirList, string(dir[len([]byte(homeDir))+1:]))
					}
				}
			}
		}()
	}
	cmd.Run()


	watcher := goutil.FS.FileWatcher()
	defer watcher.CloseWatcher("*")

	var downloadDir string

	for _, dir := range scanDirList {
		if path, err := goutil.FS.JoinPath(homeDir, dir); err == nil {
			watcher.WatchDir(path)
			if downloadDir == "" && dir == "Downloads" {
				downloadDir = path
			}
		}
	}

	watcher.OnFileChange = func(path, op string) {
		newFiles.Set(path, uint(time.Now().UnixMilli()))
		hasFiles.Set(path, uint(time.Now().UnixMilli()))
	}

	watcher.OnRemove = func(path, op string) (removeWatcher bool) {
		newFiles.Del(path)
		hasFiles.Del(path)
		return true
	}

	scanFile := make(chan string)

	running := true

	go func(){
		for {
			if !running {
				break
			}

			now := uint(time.Now().UnixMilli())
			newFiles.ForEach(func(path string, modified uint) bool {
				if now - modified > 1000 {
					scanFile <- path
					newFiles.Del(path)
				}
				return true
			})
		}
	}()

	go func(){
		for {
			file := <- scanFile

			if file == "" {
				break
			}

			// prevent removed or recently changed files from staying at the begining of the queue
			now := uint(time.Now().UnixMilli())
			if modified, ok := hasFiles.Get(file); !ok || now - modified < 1000 {
				continue
			}
			hasFiles.Del(file)

			cmd := exec.Command(`sudo`, `nice`, `-n`, `15`, `clamscan`, `&&`, `sudo`, `clamscan`, `-r`, `--bell`, `--move=/VirusScan/quarantine`, `--exclude-dir=/VirusScan/quarantine`, file)

			success := false

			if stdout, err := cmd.StdoutPipe(); err == nil {
				go func(){
					onSummary := false
					for {
						b := make([]byte, 1024)
						_, err := stdout.Read(b)
						if err != nil {
							break
						}

						if !onSummary && regex.Comp(`(?i)-+\s*scan\s+summ?[ae]ry\s*-+`).MatchRef(&b) {
							onSummary = true
							success = true
						}

						if onSummary && regex.Comp(`(?i)infected\s+files:?\s*([0-9]+)`).MatchRef(&b) {
							inf := 0
							regex.Comp(`(?i)infected\s+files:?\s*([0-9]+)`).RepFuncRef(&b, func(data func(int) []byte) []byte {
								if i, err := strconv.Atoi(string(data(1))); err == nil && i > inf {
									inf = i
								}
								return nil
							}, true)

							fmt.Println("\nFile/Dir:", file, "\n  Infected files:", inf)

							if inf == 0 && downloadDir != "" && strings.HasPrefix(file, downloadDir) {
								now := uint(time.Now().UnixMilli())
								if now - lastNotify > notifyDelay {
									lastNotify = now
									exec.Command(`notify-send`, `-i`, `/etc/aspiesoft-clamav-scanner/icon-green.png`, `-t`, `3`, `File Is Safe`, file).Run()
								}
							}else if inf != 0 {
								now := uint(time.Now().UnixMilli())
								if now - lastNotify > notifyDelay {
									lastNotify = now
									exec.Command(`notify-send`, `-i`, `/etc/aspiesoft-clamav-scanner/icon-red.png`, `-t`, `3`, `Warning: File Has Been Moved To Quarantine`, file).Run()
								}
							}

							break
						}
					}
				}()
			}

			if downloadDir != "" && strings.HasPrefix(file, downloadDir) {
				now := uint(time.Now().UnixMilli())
				if now - lastNotify > notifyDelay {
					lastNotify = now
					exec.Command(`notify-send`, `-i`, `/etc/aspiesoft-clamav-scanner/icon.png`, `-t`, `3`, `Started Scanning File`, file).Run()
				}
			}

			err := cmd.Run()
			if err != nil && !success {
				fmt.Println(err)

				if downloadDir != "" && strings.HasPrefix(file, downloadDir) {
					now := uint(time.Now().UnixMilli())
					if now - lastNotify > notifyDelay {
						lastNotify = now
						exec.Command(`notify-send`, `-i`, `/etc/aspiesoft-clamav-scanner/icon.png`, `-t`, `3`, `Error: Failed To Scan File`, file).Run()
					}
				}
			}

			time.Sleep(250 * time.Millisecond)
		}
	}()

	watcher.Wait()
	running = false
	scanFile <- ""
}
