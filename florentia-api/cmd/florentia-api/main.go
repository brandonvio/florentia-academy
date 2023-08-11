package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/brandonvio/florentia.academy/cmd/florentia-api/docs"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

var ginLambda *ginadapter.GinLambda

// @BasePath /api/v1
// PingExample godoc
// @Summary ping example
// @Schemes
// @Description do ping
// @Tags example
// @Accept json
// @Produce json
// @Success 200 {string} Helloworld
// @Router /example/helloworld [get]
func Helloworld(g *gin.Context) {
	g.JSON(http.StatusOK, fmt.Sprintf("hello world! it is %s", time.Now().Format(time.RFC3339)))
}

func Handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return ginLambda.ProxyWithContext(ctx, request)
}

func main() {
	log.Println("starting up gin server for florentia-api")
	g := gin.Default()
	docs.SwaggerInfo.BasePath = "/api/v1"

	v1 := g.Group("/api/v1")
	{
		eg := v1.Group("/example")
		{
			eg.GET("/helloworld", Helloworld)
		}
	}

	g.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
	http.ListenAndServe(":8080", g)

	env := os.Getenv("GIN_MODE")
	if env == "release" {
		log.Println("starting up gin lambda for florentia-api")
		ginLambda = ginadapter.New(g)
		lambda.Start(Handler)
	} else {
		log.Println("starting up gin server for florentia-api")
		g.Run(":8080")
	}
}
