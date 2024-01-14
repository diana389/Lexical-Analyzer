public class SimpleCalculator {
    private double operand1;
    private double operand2;
    private double differenceResult;

    public SimpleCalculator(double operand1, double operand2) {
        this.operand1 = operand1;
        this.operand2 = operand2;
    }

    public void setOperand1(double operand1) {
        this.operand1 = operand1;
    }

    public void setOperand2(double operand2) {
        this.operand2 = operand2;
    }

    public void performOperations() {
        double sumResult = add();
        differenceResult = subtract();

        System.out.println("Sum: " + sumResult);
        System.out.println("Difference: " + differenceResult);

        MathUtility mathUtility = new MathUtility(operand1, operand2);
        double productResult = mathUtility.multiply();
        System.out.println("Product: " + productResult);
    }

    private double add() {
        return operand1 + operand2;
    }

    private double subtract() {
        return operand1 - operand2;
    }

    public double getDifferenceResult() {
        return differenceResult;
    }

    public static void main(String[] args) {
        SimpleCalculator calculator = new SimpleCalculator(10.5, 5.2);

        calculator.performOperations();

        calculator.setOperand1(0);
        calculator.setOperand2(0);

        calculator.performOperations();

        double diffResult = calculator.getDifferenceResult();
        System.out.println("Retrieved Difference Result: " + diffResult);

        MathUtility[] mathUtility = new MathUtility[100];

        int i = 0;
        while(i < 100) {
            mathUtility[i] = new MathUtility(i, i + 1);
            i++;
        }

        MathUtility obj = new MathUtility(10, 20);
    }
}

class MathUtility {
    private double operand1;
    private double operand2;

    public MathUtility(double operand1, double operand2) {
        this.operand1 = operand1;
        this.operand2 = operand2;
    }

    public double multiply() {
        return operand1 * operand2;
    }

    public double getOperand1() {
        return operand1;
    }

    public double getOperand2() {
        return operand2;
    }
}

// class MathUtility2 {
//     private double operand1;
//     private double operand2;

//     public MathUtility2(double operand1, double operand2) {
//         this.operand1 = operand1;
//         this.operand2 = operand2;
//     }

//     public double multiply() {
//         return operand1 * operand2;
//     }

//     public double getOperand1() {
//         return operand1;
//     }

//     public double getOperand2() {
//         return operand2;
//     }
// }