import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

class Simulator {
    int numOfCoeffs;
    int populationSize;
    int y;
    int[] coeffs;
    float invertedCoeffSum;
    float[] invertedCoeffs;
    int[][] x;
    int[] survivalRates;
    double fitness;
    float[] probabilityOfChoice;
    boolean[] reproducable;
    
    String task = "";

    Simulator(int numOfCoeffs, int populationSize, int y) {
        this.numOfCoeffs = numOfCoeffs;
        this.populationSize = populationSize;
        this.y = y;

        this.survivalRates = new int[populationSize];
        this.x = new int[populationSize][numOfCoeffs];
        this.probabilityOfChoice = new float[populationSize];
        this.invertedCoeffs = new float[populationSize];
        this.reproducable = new boolean[populationSize];
    }

    void update() {
        this.survivalRates = new int[populationSize];
        this.probabilityOfChoice = new float[populationSize];
        this.invertedCoeffs = new float[populationSize];
        this.reproducable = new boolean[populationSize];
    }

    int[] generateRandomArray(int size, int start, int end) {
        return new Random().ints(size, start, end).toArray();
    }

    void calculateX() {
        for (int i = 0; i < this.x.length; i++) {
            x[i] = generateRandomArray(this.numOfCoeffs, 1, y);
        }
    }

    void calculateCoeffs() {
        this.coeffs = generateRandomArray(this.numOfCoeffs, 1, (int)y/4);
    }

    void calculateInvertedCoeffs() {
        for (int i = 0; i < this.invertedCoeffs.length; i++) {
            this.invertedCoeffs[i] = (float)(1) / this.survivalRates[i];
        }

        calculateInvertedCoeffSum();
    }

    void calculateInvertedCoeffSum() {
        for (float invertedCoeff : this.invertedCoeffs) {
            this.invertedCoeffSum += invertedCoeff;
        }
    }

    void calculateSurvivalRates() {
        for (int i = 0; i < this.survivalRates.length; i++) {
            int sum = 0;
            for (int j = 0; j < this.numOfCoeffs; j++) {
                sum += this.coeffs[j] * this.x[i][j];
            }
            this.survivalRates[i] = Math.abs(sum - y);
        }
        this.fitness = Arrays.stream(this.survivalRates).average().orElse(Double.NaN);
    }

    private int[] getChildSurviveRate(int[][] childs) {
        int[] survivalRate = new int[childs.length];
        for (int i = 0; i < survivalRate.length; i++) {
            int sum = 0;
            for (int j = 0; j < this.numOfCoeffs; j++) {
                sum += this.coeffs[j] * childs[i][j];
            }
            survivalRate[i] = Math.abs(sum - y);
        }
        return survivalRate;
    }

    double getChildFitness(int[] survivalRate) {
        return Arrays.stream(survivalRate).average().orElse(Double.NaN);
    }

    void calculateProbabilityOfChoice() {
        for (int i = 0; i < this.probabilityOfChoice.length; i++) {
            this.probabilityOfChoice[i] = this.invertedCoeffs[i] / this.invertedCoeffSum;
        }
    }

    void calculateReproducable() {
        double[] parts = new double[populationSize];
        for (int i = 0; i < 10; i++) {
            double[] parts_t = new Random().doubles(populationSize, 0, 2).toArray();
            for (int j = 0; j < parts.length; j++) {
                parts[j] += parts_t[j];
            }
        }

        for (int i = 0; i < this.probabilityOfChoice.length; i++) {
            this.reproducable[i] = (parts[i] >= (10 - this.probabilityOfChoice[i])) ? true : false;
        }
    }

    void setUpParents() {
        calculateX();
        calculateCoeffs();
    }

    int[][] getPairs() {
        int[][] pairs = new int[(int)Math.pow(this.populationSize, 2)][2];
        ArrayList<int[]> pairsList = new ArrayList<int[]>();

        int k = 0;
        while (k < pairs.length - 1) {
            for(int i = 0; i < populationSize; i++) {
                for (int j = 0; j < populationSize; j++) {
                    pairs[k][0] = i;
                    pairs[k][1] = j;

                    if (i != j) pairsList.add(pairs[k]);
                    k++;
                }
            }
        }

        float[] sums = new float[pairsList.size()];
        for (int i = 0; i < sums.length; i++) {
            sums[i] = (this.probabilityOfChoice[pairsList.get(i)[0]] + this.probabilityOfChoice[pairsList.get(i)[1]]);
        }

        for (int i = 0; i < sums.length; i++) {
            for (int j = 0; j < sums.length; j++) {
                if (sums[i] > sums[j]) {
                    int[] temp_p;
                    float temp;

                    temp = sums[i];
                    sums[i] = sums[j];
                    sums[j] = temp;

                    temp_p = pairsList.get(i);
                    pairsList.set(i, pairsList.get(j));
                    pairsList.set(j, temp_p);
                }
            }
        }

        int step = new Random().nextInt(populationSize - 1) + 1;
        for (int i = 0; i < pairsList.size(); i += step) {
            pairsList.remove(i);
        }

        int[][] pairs_result = new int[populationSize][];
        for (int i = 0; i < populationSize; i++) {
            pairs_result[i] = pairsList.get(i);
        }

        return pairs_result;
    }
    
    int[] getChild(int[] parentX, int[] parentY) {
        int[] child = new int[parentX.length];

        int separator = new Random().nextInt(child.length - 2) + 1;
        int choice = new Random().nextInt(2) + 1;

        for (int i = 0; i < separator; i++) {
            child[i] = (choice == 1) ? parentX[i] : parentY[i];
        }

        for (int i = separator; i < child.length; i++) {
            child[i] = (choice == 1) ? parentY[i] : parentX[i];
        }
        return child;
    }

    int[][] mutate(int[][] childs) {
        Random rand = new Random();

        int[] childIndexes = rand.ints((int)(childs.length/2), 0, (int)(childs.length)).toArray();
        for (int index : childIndexes) {
            int[] elements = rand.ints((int)(childs[index].length/2), 0, (int)(childs[index].length)).toArray();
            for (int elementIndex : elements) {
                childs[index][elementIndex] = rand.nextInt(y) + 1;
            }
        }

        return childs;
    }

    int findResult(int[] survivalRate) {
        int index = -1;
        for (int i = 0; i < survivalRate.length; i++) {
            if (survivalRate[i] <= 1) return i;
        }
        return index;
    }

    String getTask() {
      String temp = "";
      for (int i = 0; i < this.numOfCoeffs; i++) {
          temp += this.coeffs[i] + "*x" + i;
          if (i != this.numOfCoeffs - 1) temp += " + ";
      }
      temp += " = " + this.y + "\n";
      return temp;
    }

    int[] run() {
        int[] result = new int[this.numOfCoeffs];
        boolean started = true;

        while(started) {
            calculateSurvivalRates();
            calculateInvertedCoeffs();
            calculateProbabilityOfChoice();

            calculateReproducable();

            int[][] pairs = getPairs();

            int[][] childs = new int[pairs.length][numOfCoeffs];

            for (int i = 0; i < childs.length; i++) {
                childs[i] = getChild(this.x[pairs[i][0]], this.x[pairs[i][1]]);
            }

            childs = mutate(childs);
            int[] childSurvivalRate = getChildSurviveRate(childs);

            int res_i = findResult(childSurvivalRate);

            if (res_i != -1) {
                started = false;
                result = childs[res_i];
            } else {
                this.x = childs;
                this.populationSize = this.x.length;
                update();
            }
        }

        return result;
    }
}
