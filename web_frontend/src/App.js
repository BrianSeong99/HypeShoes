import React from "react";
import { Line } from "react-chartjs-2";
import "chartjs-plugin-streaming";
import "./styles.css";
import moment from "moment";

const Chart = require("react-chartjs-2").Chart;

const chartColors = {
  red: "rgb(255, 99, 132)",
  orange: "rgb(255, 159, 64)",
  yellow: "rgb(255, 205, 86)",
  green: "rgb(75, 192, 192)",
  blue: "rgb(54, 162, 235)",
  purple: "rgb(153, 102, 255)",
  grey: "rgb(201, 203, 207)",
  black: "rgb(0,0,0)"
};

const color = Chart.helpers.color;
const data = {
  datasets: [
    {
      label: "FSR0",
      backgroundColor: color(chartColors.orange)
        .alpha(0.5)
        .rgbString(),
      borderColor: chartColors.green,
      fill: false,
      lineTension: 0,
      borderDash: [8, 4],
      data: []
    },
    {
      label: "FSR1",
      backgroundColor: color(chartColors.orange)
        .alpha(0.5)
        .rgbString(),
      borderColor: chartColors.blue,
      fill: false,
      lineTension: 0,
      borderDash: [8, 4],
      data: []
    },
    {
      label: "FSR2",
      backgroundColor: color(chartColors.orange)
        .alpha(0.5)
        .rgbString(),
      borderColor: chartColors.purple,
      fill: false,
      lineTension: 0,
      borderDash: [8, 4],
      data: []
    },
    {
      label: "FSR3",
      backgroundColor: color(chartColors.orange)
        .alpha(0.5)
        .rgbString(),
      borderColor: chartColors.grey,
      fill: false,
      lineTension: 0,
      borderDash: [8, 4],
      data: []
    },
    {
      label: "FSR4",
      backgroundColor: color(chartColors.orange)
        .alpha(0.5)
        .rgbString(),
      borderColor: chartColors.black,
      fill: false,
      lineTension: 0,
      borderDash: [8, 4],
      data: []
    },
    // {
    //   label: "AccelX",
    //   backgroundColor: color(chartColors.red)
    //     .alpha(0.5)
    //     .rgbString(),
    //   borderColor: chartColors.red,
    //   fill: false,
    //   lineTension: 0,
    //   borderDash: [8, 4],
    //   data: []
    // },
    // {
    //   label: "AccelY",
    //   backgroundColor: color(chartColors.orange)
    //     .alpha(0.5)
    //     .rgbString(),
    //   borderColor: chartColors.red,
    //   fill: false,
    //   lineTension: 0,
    //   borderDash: [8, 4],
    //   data: []
    // },
    // {
    //   label: "AccelZ",
    //   backgroundColor: color(chartColors.yellow)
    //     .alpha(0.5)
    //     .rgbString(),
    //   borderColor: chartColors.red,
    //   fill: false,
    //   lineTension: 0,
    //   borderDash: [8, 4],
    //   data: []
    // }
  ]
};

const getRecordData = async function() {
  var requestOptions = {
    method: 'GET',
    redirect: 'follow'
  };
  
  let result = await fetch("http://127.0.0.1:5001/user/data/record", requestOptions)
    .then(response => response.json())
    .then(result => result)
    .catch(error => console.log('error', error));
  
  // console.log(result['right_sequence_data']);
  return result['right_sequence_data'];
}

const options = {
  elements: {
    line: {
      tension: 0.5
    }
  },
  scales: {
    xAxes: [
      {
        type: "realtime",
        distribution: "linear",
        realtime: {
          onRefresh: async function(chart) {
            let recordData = await getRecordData();
            console.log(recordData[recordData.length - 1][11]);
            const now = moment();
            chart.data.datasets[0].data.push({
              x: now,
              y: recordData[recordData.length - 1][0] * 10 / 3.3
            });
            chart.data.datasets[1].data.push({
              x: now,
              y: recordData[recordData.length - 1][1] * 10 / 3.3
            });
            chart.data.datasets[2].data.push({
              x: now,
              y: recordData[recordData.length - 1][2] * 10 / 3.3
            });
            chart.data.datasets[3].data.push({
              x: now,
              y: recordData[recordData.length - 1][3] * 10 / 3.3
            });
            chart.data.datasets[4].data.push({
              x: now,
              y: recordData[recordData.length - 1][4] * 10 / 3.3
            });
            // chart.data.datasets[5].data.push({
            //   x: now,
            //   y: recordData[recordData.length - 1][5]
            // });
            // chart.data.datasets[6].data.push({
            //   x: now,
            //   y: recordData[recordData.length - 1][6]
            // });
            // chart.data.datasets[7].data.push({
            //   x: now,
            //   y: recordData[recordData.length - 1][7]
            // });
            console.log(chart.data.datasets[0].data);
          },
          delay: 1000,
          time: {
            displayFormat: "h:mm"
          }
        },
        ticks: {
          displayFormats: 1,
          maxRotation: 0,
          minRotation: 0,
          stepSize: 1,
          maxTicksLimit: 30,
          minUnit: "second",
          source: "auto",
          autoSkip: true,
          callback: function(value) {
            return moment(value, "HH:mm:ss").format("mm:ss");
          }
        }
      }
    ],
    yAxes: [
      {
        ticks: {
          beginAtZero: true,
          max: 4
        }
      }
    ]
  }
};

function App() {
  return (
    <div className="App">
      <Line data={data} options={options} />
    </div>
  );
}

export default App;
