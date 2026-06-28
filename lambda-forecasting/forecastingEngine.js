export function calculateWeightedMovingAverage(weeklyDemand = []) {
    const recentWeeks = weeklyDemand.slice(-3);

    if (recentWeeks.length === 0) {
        return 0;
    }

    const baseWeights = [0.2, 0.3, 0.5];
    const weights = baseWeights.slice(3 - recentWeeks.length);

    const weightedTotal = recentWeeks.reduce(
        (total, demand, index) => total + Number(demand || 0) * weights[index],
        0,
    );

    const totalWeight = weights.reduce(
        (total, weight) => total + weight,
        0,
    );

    return totalWeight > 0 ? weightedTotal / totalWeight : 0;
}

export function buildInventoryForecast({
                                           weeklyDemand = [],
                                           onHandQuantity = 0,
                                           allocatedQuantity = 0,
                                           lowStockThreshold = 0,
                                           safetyStock = 0,
                                       }) {
    const weeklyForecast = calculateWeightedMovingAverage(weeklyDemand);

    // Forecast for approximately 30 days
    const forecastedDemand = Math.ceil(weeklyForecast * 4.29);

    const availableQuantity = Math.max(
        0,
        Number(onHandQuantity) - Number(allocatedQuantity),
    );

    const suggestedRestock = Math.max(
        0,
        forecastedDemand + Number(safetyStock) - availableQuantity,
    );

    let status = "STABLE";

    if (availableQuantity <= Number(lowStockThreshold)) {
        status = "LOW";
    } else if (suggestedRestock > 0) {
        status = "RISK";
    }

    return {
        onHandQuantity: Number(onHandQuantity),
        allocatedQuantity: Number(allocatedQuantity),
        availableQuantity,
        forecastedDemand,
        suggestedRestock,
        status,
    };
}