import { type NextRequest, NextResponse } from "next/server"
import { checkAccountNumberApproval } from "@/lib/application-service"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const accountNumber = searchParams.get("accountNumber")

    if (!accountNumber) {
      return NextResponse.json({ success: false, message: "Account number is required" }, { status: 400 })
    }

    const status = await checkAccountNumberApproval(accountNumber)

    return NextResponse.json({
      success: true,
      status,
    })
  } catch (error) {
    console.error("[v0] Error checking account status:", error)
    return NextResponse.json({ success: false, message: "Internal server error" }, { status: 500 })
  }
}
