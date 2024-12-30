import express, { Request, Response, Application } from "express";
import dotenv from "dotenv";
import axios, { AxiosError } from "axios";
import requestConfig from "./requestConfig.json";

//For env File
dotenv.config();

const app: Application = express();
const port = process.env.PORT || 8000;

app.get("/", (req: Request, res: Response) => {
  res.send("Welcome to Express & TypeScript Server");
});

app.get("/getStations", async (_req: Request, res: Response) => {
  try {
    const response = await axios.get(requestConfig.url, {
      headers: requestConfig.headers,
    });

    res.json(response.data);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError;
      res
        .status(parseInt(axiosError.code || "") || 500)
        .send(axiosError.message);
    }

    res.status(500).send("Unknown error occurred");
  }
});

app.listen(port, () => {
  console.log(`Server is Fire at http://localhost:${port}`);
});
