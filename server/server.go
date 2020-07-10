package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"github.com/gin-gonic/gin"
)

var updateMutex sync.Mutex

func updateGraphs() {
	updateMutex.Lock()
	defer updateMutex.Unlock()
	files, err := filepath.Glob("data/*.json")
	if err != nil {
		fmt.Println(err)
		return
	}
	args := []string{}
	for _, file := range files {
		args = append(args, file)
		args = append(args, strings.TrimSuffix(filepath.Base(file), filepath.Ext(file)))
	}
	fmt.Printf("%v", args)
	cmd := exec.Command("./balance.sh", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}
	cmd = exec.Command("./vehicles.sh", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}
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
		err := os.Remove("data/" + name + ".json")
		if err != nil {
			c.String(500, err.Error())
			return
		}
		c.String(204, "")
	})
	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
