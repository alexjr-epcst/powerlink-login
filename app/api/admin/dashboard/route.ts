import { NextResponse } from "next/server"
import { mockDataStore } from "@/lib/mock-data-store"

export async function GET() {
  try {
    console.log("[v0] Dashboard API called")

    // Get data from mock store
    const consumers = mockDataStore.getConsumers()
    const bills = mockDataStore.getBills()
    const applications = mockDataStore.getApplications()

    // Calculate stats
    const totalConsumers = consumers.length
    const unpaidBills = bills
      .filter((bill: any) => bill.status !== "paid")
      .reduce((sum: number, bill: any) => sum + (bill.amount || 0), 0)

    const newApplications = applications.filter((app: any) => app.status === "pending").length

    const readingsNeeded = consumers.filter((consumer: any) => consumer.status === "active").length

    // Generate energy consumption data
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    const energyConsumption = months.map((month) => ({
      month,
      consumption: Math.floor(Math.random() * 5000) + 1000,
    }))

    // Recent activities
    const recentActivities = [
      {
        id: 1,
        type: "new_consumer",
        title: "New Consumer Registration",
        description: `${totalConsumers} total consumers registered`,
        icon: "user",
        color: "blue",
      },
      {
        id: 2,
        type: "payment",
        title: "Unpaid Bills",
        description: `₱${unpaidBills.toLocaleString()} total unpaid`,
        icon: "credit-card",
        color: "green",
      },
      {
        id: 3,
        type: "application",
        title: "Pending Applications",
        description: `${newApplications} applications awaiting approval`,
        icon: "file",
        color: "yellow",
      },
      {
        id: 4,
        type: "reading",
        title: "Readings Needed",
        description: `${readingsNeeded} meter readings due`,
        icon: "activity",
        color: "red",
      },
    ]

    return NextResponse.json(
      {
        stats: {
          totalConsumers: { value: totalConsumers, change: 5.2, trend: "up" },
          unpaidBills: { value: unpaidBills, change: -2.1, trend: "down" },
          newApplications: { value: newApplications, change: newApplications, trend: "up" },
          readingsNeeded: { value: readingsNeeded, change: 0, trend: "neutral" },
        },
        energyConsumption,
        recentActivities,
      },
      { status: 200 },
    )
  } catch (error) {
    console.error("[v0] Error in dashboard API:", error)
    // Return fallback data even on error
    return NextResponse.json(
      {
        stats: {
          totalConsumers: { value: 0, change: 0, trend: "neutral" },
          unpaidBills: { value: 0, change: 0, trend: "neutral" },
          newApplications: { value: 0, change: 0, trend: "neutral" },
          readingsNeeded: { value: 0, change: 0, trend: "neutral" },
        },
        energyConsumption: [
          { month: "Jan", consumption: 0 },
          { month: "Feb", consumption: 0 },
          { month: "Mar", consumption: 0 },
          { month: "Apr", consumption: 0 },
          { month: "May", consumption: 0 },
          { month: "Jun", consumption: 0 },
        ],
        recentActivities: [],
      },
      { status: 200 },
    )
  }
}
