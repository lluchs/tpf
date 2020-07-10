package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sync"

	"github.com/gin-gonic/gin"
)

var updateMutex sync.Mutex

func runGraphCmd(outfile, script string, args []string) error {
	cmd := exec.Command(script, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	tmpfile := outfile + ".tmp"
	cmd.Env = append(cmd.Env, "OUTPUT="+tmpfile)
	if err := cmd.Run(); err != nil {
		return err
	}
	return os.Rename(tmpfile, outfile)
}

func updateGraphs() {
	updateMutex.Lock()
	defer updateMutex.Unlock()
	files, err := filepath.Glob("data/*.json")
	if err != nil {
		fmt.Println(err)
		return
	}
	if err = runGraphCmd("graph/balance.svg", "./balance.sh", files); err != nil {
		fmt.Println(err)
		return
	}
	if err = runGraphCmd("graph/vehicles.svg", "./vehicles.sh", files); err != nil {
		fmt.Println(err)
		return
	}
}

var nameRe = regexp.MustCompile(`^\w+$`)

// validName validates names.
func validName(name string) bool {
	return nameRe.MatchString(name)
}

func main() {
	os.MkdirAll("data", 0755)
	os.MkdirAll("graph", 0755)

	r := gin.Default()
	r.Static("/graph", "./graph")
	r.GET("/", func(c *gin.Context) {
		c.File("index.html")
	})
	r.POST("/data/:name", func(c *gin.Context) {
		name := c.Param("name")
		if !validName(name) {
			c.String(400, "invalid name")
			return
		}
		f, err := os.OpenFile("data/"+name+".json", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			c.String(500, err.Error())
			return
		}
		defer f.Close()
		_, err = io.Copy(f, c.Request.Body)
		if err != nil {
			c.String(500, err.Error())
			return
		}
		c.String(204, "")
		go updateGraphs()
	})
	r.DELETE("/data/:name", func(c *gin.Context) {
		name := c.Param("name")
		if !validName(name) {
			c.String(400, "invalid name")
			return
		}
		err := os.Remove("data/" + name + ".json")
		if err != nil {
			c.String(500, err.Error())
			return
		}
		c.String(204, "")
	})
	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
