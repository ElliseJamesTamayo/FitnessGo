"use client";

import Link from "next/link";
import { useEffect, useMemo, useState, type ChangeEvent, type ReactNode } from "react";
import {
    ArrowUpRight,
    CalendarDays,
    CheckCircle2,
    ChevronDown,
    CircleAlert,
    Clock3,
    Eye,
    FileImage,
    Filter,
    LogOut,
    Pencil,
    ReceiptText,
    RefreshCw,
    QrCode,
    Search,
    ShieldAlert,
    Store,
    Upload,
    X,
    XCircle,
} from "lucide-react";

type Plan = "Starter" | "Business" | "Enterprise";
type PaymentStatus = "PENDING" | "APPROVED" | "REJECTED";
type ReviewAction = "approve" | "reject" | null;

type GCashPaymentSettings = {
    accountName: string;
    gcashNumber: string;
    instruction: string;
    qrImage: string;
};

const PAYMENT_SETTINGS_STORAGE_KEY = "stocknbook_platform_gcash_settings";

const defaultGcashPaymentSettings: GCashPaymentSettings = {
    accountName: "StockNBook Admin",
    gcashNumber: "0917 123 4567",
    instruction: "Include your store name",
    qrImage: "/gcash-qr.png",
};

type PaymentRequest = {
    id: string;
    storeName: string;
    ownerName: string;
    ownerEmail: string;
    businessId: string;
    currentPlan: Plan;
    requestedPlan: Plan;
    amount: number;
    referenceNumber: string;
    paymentDate: string;
    submittedAt: string;
    status: PaymentStatus;
    proofFileName: string;
};

type ExpiringSubscription = {
    storeName: string;
    ownerEmail: string;
    plan: Plan;
    expirationDate: string;
    daysLeft: number;
    initials: string;
};

const initialPaymentRequests: PaymentRequest[] = [
    {
        id: "PAY-20260626-001",
        storeName: "ABC Party Supplies",
        ownerName: "Juan Dela Cruz",
        ownerEmail: "abcparty@gmail.com",
        businessId: "BUS-00015",
        currentPlan: "Starter",
        requestedPlan: "Business",
        amount: 499,
        referenceNumber: "1234567890123",
        paymentDate: "June 26, 2026",
        submittedAt: "June 26, 2026, 10:30 AM",
        status: "PENDING",
        proofFileName: "gcash-proof-abc-party.jpg",
    },
    {
        id: "PAY-20260626-002",
        storeName: "Happy Events",
        ownerName: "Maria Santos",
        ownerEmail: "happyevents@gmail.com",
        businessId: "BUS-00019",
        currentPlan: "Business",
        requestedPlan: "Enterprise",
        amount: 1299,
        referenceNumber: "9827345610123",
        paymentDate: "June 26, 2026",
        submittedAt: "June 26, 2026, 9:15 AM",
        status: "PENDING",
        proofFileName: "gcash-proof-happy-events.jpg",
    },
    {
        id: "PAY-20260625-003",
        storeName: "Party World",
        ownerName: "Anne Reyes",
        ownerEmail: "partyworld@gmail.com",
        businessId: "BUS-00023",
        currentPlan: "Starter",
        requestedPlan: "Business",
        amount: 499,
        referenceNumber: "6248091345780",
        paymentDate: "June 25, 2026",
        submittedAt: "June 25, 2026, 4:45 PM",
        status: "PENDING",
        proofFileName: "gcash-proof-party-world.jpg",
    },
    {
        id: "PAY-20260625-004",
        storeName: "Fiesta Supplier",
        ownerName: "Rina Flores",
        ownerEmail: "fiesta.supplier@gmail.com",
        businessId: "BUS-00027",
        currentPlan: "Starter",
        requestedPlan: "Business",
        amount: 499,
        referenceNumber: "7713259874601",
        paymentDate: "June 25, 2026",
        submittedAt: "June 25, 2026, 2:20 PM",
        status: "PENDING",
        proofFileName: "gcash-proof-fiesta-supplier.jpg",
    },
    {
        id: "PAY-20260625-005",
        storeName: "J&P Party Needs",
        ownerName: "Jose Panganiban",
        ownerEmail: "jnpparty@gmail.com",
        businessId: "BUS-00031",
        currentPlan: "Business",
        requestedPlan: "Enterprise",
        amount: 1299,
        referenceNumber: "4561237890412",
        paymentDate: "June 25, 2026",
        submittedAt: "June 25, 2026, 1:05 PM",
        status: "PENDING",
        proofFileName: "gcash-proof-jp-party-needs.jpg",
    },
];

const expiringSubscriptions: ExpiringSubscription[] = [
    {
        storeName: "Party World",
        ownerEmail: "partyworld@gmail.com",
        plan: "Enterprise",
        expirationDate: "June 29, 2026",
        daysLeft: 3,
        initials: "PW",
    },
    {
        storeName: "CE Events Supply",
        ownerEmail: "ceevents@gmail.com",
        plan: "Business",
        expirationDate: "July 2, 2026",
        daysLeft: 6,
        initials: "CE",
    },
    {
        storeName: "ABC Party Supplies",
        ownerEmail: "abcparty@gmail.com",
        plan: "Business",
        expirationDate: "July 3, 2026",
        daysLeft: 7,
        initials: "AB",
    },
    {
        storeName: "Fiesta Supplier",
        ownerEmail: "fiesta.supplier@gmail.com",
        plan: "Business",
        expirationDate: "July 4, 2026",
        daysLeft: 8,
        initials: "FS",
    },
];

const revenueValues = [
    4200, 3900, 4400, 5100, 4800, 6100, 6800, 5900, 7200, 8400, 7900, 9200,
    8700, 7400, 6900, 7600, 8800, 9700, 8900, 10100, 9400, 10600, 10986,
];

const currency = new Intl.NumberFormat("en-PH", {
    style: "currency",
    currency: "PHP",
    maximumFractionDigits: 0,
});

function planClasses(plan: Plan) {
    if (plan === "Starter") {
        return "adm-plan-starter";
    }

    if (plan === "Business") {
        return "adm-plan-business";
    }

    return "adm-plan-enterprise";
}

function PaymentStatusBadge({ status }: { status: PaymentStatus }) {
    const statusClass =
        status === "PENDING"
            ? "adm-status-pending"
            : status === "APPROVED"
                ? "adm-status-approved"
                : "adm-status-rejected";

    return (
        <span
            className={`adm-status inline-flex items-center rounded-full px-2.5 py-1 text-[10px] font-bold tracking-wide ${statusClass}`}
        >
            {status}
        </span>
    );
}

function PlanBadge({ plan }: { plan: Plan }) {
    return (
        <span
            className={`adm-plan inline-flex rounded-md border px-2 py-1 text-[10px] font-bold ${planClasses(plan)}`}
        >
            {plan}
        </span>
    );
}

function SummaryCard({
                         title,
                         value,
                         helper,
                         icon,
                         iconClass,
                     }: {
    title: string;
    value: string | number;
    helper: string;
    icon: ReactNode;
    iconClass: string;
}) {
    return (
        <article className="adm-card h-[112px] rounded-[14px] border p-4 transition hover:-translate-y-0.5">
            <div className="flex h-full items-start justify-between gap-4">
                <div className="min-w-0">
                    <p className="adm-title text-xs font-semibold">{title}</p>
                    <p className="adm-title mt-1 text-[25px] font-bold leading-tight tracking-[-0.03em]">
                        {value}
                    </p>
                    <p className="adm-muted mt-2 text-xs font-medium">{helper}</p>
                </div>
                <span className={`adm-summary-icon flex h-9 w-9 shrink-0 self-center items-center justify-center rounded-xl leading-none ${iconClass}`}>
                    {icon}
                </span>
            </div>
        </article>
    );
}

export default function PlatformAdminDashboardPage() {
    const [paymentRequests, setPaymentRequests] = useState(initialPaymentRequests);
    const [searchQuery, setSearchQuery] = useState("");
    const [selectedPayment, setSelectedPayment] = useState<PaymentRequest | null>(null);
    const [reviewAction, setReviewAction] = useState<ReviewAction>(null);
    const [rejectionReason, setRejectionReason] = useState("");
    const [rejectionNote, setRejectionNote] = useState("");
    const [gcashSettings, setGcashSettings] = useState<GCashPaymentSettings>(defaultGcashPaymentSettings);
    const [gcashSettingsForm, setGcashSettingsForm] = useState<GCashPaymentSettings>(defaultGcashPaymentSettings);
    const [isGcashSettingsOpen, setIsGcashSettingsOpen] = useState(false);

    useEffect(() => {
        try {
            const savedSettings = window.localStorage.getItem(PAYMENT_SETTINGS_STORAGE_KEY);

            if (!savedSettings) {
                return;
            }

            const parsedSettings = JSON.parse(savedSettings) as Partial<GCashPaymentSettings>;
            const resolvedSettings = {
                ...defaultGcashPaymentSettings,
                ...parsedSettings,
            };

            setGcashSettings(resolvedSettings);
            setGcashSettingsForm(resolvedSettings);
        } catch {
            // Keep the default GCash details when locally saved data is unavailable or invalid.
        }
    }, []);

    function openGcashSettings() {
        setGcashSettingsForm(gcashSettings);
        setIsGcashSettingsOpen(true);
    }

    function closeGcashSettings() {
        setGcashSettingsForm(gcashSettings);
        setIsGcashSettingsOpen(false);
    }

    function handleGcashQrUpload(event: ChangeEvent<HTMLInputElement>) {
        const file = event.target.files?.[0];

        if (!file || !file.type.startsWith("image/")) {
            return;
        }

        const fileReader = new FileReader();

        fileReader.onload = () => {
            const uploadedImage = String(fileReader.result || "");

            if (!uploadedImage) {
                return;
            }

            setGcashSettingsForm((currentSettings) => ({
                ...currentSettings,
                qrImage: uploadedImage,
            }));
        };

        fileReader.readAsDataURL(file);
    }

    function saveGcashSettings() {
        const savedSettings: GCashPaymentSettings = {
            accountName: gcashSettingsForm.accountName.trim() || defaultGcashPaymentSettings.accountName,
            gcashNumber: gcashSettingsForm.gcashNumber.trim() || defaultGcashPaymentSettings.gcashNumber,
            instruction: gcashSettingsForm.instruction.trim() || defaultGcashPaymentSettings.instruction,
            qrImage: gcashSettingsForm.qrImage || defaultGcashPaymentSettings.qrImage,
        };

        setGcashSettings(savedSettings);
        setGcashSettingsForm(savedSettings);

        try {
            window.localStorage.setItem(PAYMENT_SETTINGS_STORAGE_KEY, JSON.stringify(savedSettings));
        } catch {
            // The updated settings still remain available for the current browser session.
        }

        setIsGcashSettingsOpen(false);
    }

    function handleLogout() {
        const sessionKeys = [
            "token",
            "accessToken",
            "admin_token",
            "platform_admin_token",
            "user",
            "userData",
            "platformAdmin",
            "platform_admin",
            "role",
            "permissions",
            "profile",
            "stocknbook_user",
        ];

        sessionKeys.forEach((key) => {
            window.localStorage.removeItem(key);
            window.sessionStorage.removeItem(key);
        });

        // Sends the admin to: app/platform-admin-login/page.tsx
        window.location.replace("/");
    }

    const pendingCount = paymentRequests.filter((payment) => payment.status === "PENDING").length;

    const filteredPayments = useMemo(() => {
        const searchTerm = searchQuery.trim().toLowerCase();

        const pendingPayments = paymentRequests.filter(
            (payment) => payment.status === "PENDING",
        );

        if (!searchTerm) {
            return pendingPayments;
        }

        return pendingPayments.filter((payment) =>
            [
                payment.storeName,
                payment.ownerName,
                payment.ownerEmail,
                payment.referenceNumber,
            ].some((value) => value.toLowerCase().includes(searchTerm)),
        );
    }, [paymentRequests, searchQuery]);

    const chart = useMemo(() => {
        const width = 760;
        const baseline = 198;
        const topPadding = 22;
        const leftPadding = 18;
        const rightPadding = 16;
        const minimum = Math.min(...revenueValues);
        const maximum = Math.max(...revenueValues);
        const availableWidth = width - leftPadding - rightPadding;
        const usableHeight = baseline - topPadding;

        const points = revenueValues.map((value, index) => {
            const x = leftPadding + (availableWidth / (revenueValues.length - 1)) * index;
            const y =
                baseline -
                ((value - minimum) / Math.max(maximum - minimum, 1)) * usableHeight;

            return { x, y };
        });

        return {
            points,
            linePath: points.map((point) => `${point.x},${point.y}`).join(" "),
            areaPath: `M ${points[0].x},${baseline} L ${points
                .map((point) => `${point.x},${point.y}`)
                .join(" L ")} L ${points[points.length - 1].x},${baseline} Z`,
        };
    }, []);

    function openPaymentReview(payment: PaymentRequest) {
        setSelectedPayment(payment);
        setReviewAction(null);
        setRejectionReason("");
        setRejectionNote("");
    }

    function closePaymentReview() {
        setSelectedPayment(null);
        setReviewAction(null);
        setRejectionReason("");
        setRejectionNote("");
    }

    function confirmApproval() {
        if (!selectedPayment) {
            return;
        }

        setPaymentRequests((currentPayments) =>
            currentPayments.map((payment) =>
                payment.id === selectedPayment.id
                    ? { ...payment, status: "APPROVED" }
                    : payment,
            ),
        );
        closePaymentReview();
    }

    function confirmRejection() {
        if (!selectedPayment || !rejectionReason) {
            return;
        }

        setPaymentRequests((currentPayments) =>
            currentPayments.map((payment) =>
                payment.id === selectedPayment.id
                    ? { ...payment, status: "REJECTED" }
                    : payment,
            ),
        );
        closePaymentReview();
    }

    return (
        <div className="platform-admin-dashboard">
            <style>{`
                html:has(.platform-admin-dashboard),
                body:has(.platform-admin-dashboard) {
                    background: #FDFAF4 !important;
                    color: #1A1220 !important;
                    color-scheme: light !important;
                }

                body:has(.platform-admin-dashboard) header {
                    background: #FDFAF4 !important;
                    border-color: #EBE4F0 !important;
                }

                body:has(.platform-admin-dashboard) header h1 {
                    color: #1A1220 !important;
                }

                body:has(.platform-admin-dashboard) header p {
                    color: #3B1B88 !important;
                }

                .platform-admin-dashboard {
                    min-height: calc(100vh - 80px) !important;
                    background: #FDFAF4 !important;
                    color: #1A1220 !important;
                    color-scheme: light !important;
                }

                .platform-admin-dashboard * {
                    color: #1A1220 !important;
                    opacity: 1 !important;
                    text-shadow: none !important;
                }

                .platform-admin-dashboard .adm-title { color: #1A1220 !important; }
                .platform-admin-dashboard .adm-muted { color: #776E84 !important; }
                .platform-admin-dashboard .adm-accent { color: #3B1B88 !important; }
                .platform-admin-dashboard .adm-label { color: #6B32BE !important; }
                .platform-admin-dashboard .adm-warning { color: #8A5A00 !important; }
                .platform-admin-dashboard .adm-danger { color: #B42318 !important; }
                .platform-admin-dashboard .adm-success { color: #226B36 !important; }
                .platform-admin-dashboard .text-white { color: #FFFFFF !important; }
                .platform-admin-dashboard [class*="text-[#3B1B88]"] { color: #3B1B88 !important; }
                .platform-admin-dashboard [class*="text-[#8A5A00]"] { color: #8A5A00 !important; }
                .platform-admin-dashboard [class*="text-[#1D4ED8]"] { color: #1D4ED8 !important; }

                .platform-admin-dashboard .text-slate-900 { color: #1A1220 !important; }
                .platform-admin-dashboard .text-slate-800 { color: #1A1220 !important; }
                .platform-admin-dashboard .text-slate-700 { color: #4C4556 !important; }
                .platform-admin-dashboard .text-slate-600 { color: #665D79 !important; }
                .platform-admin-dashboard .text-slate-500 { color: #776E84 !important; }
                .platform-admin-dashboard .text-slate-400 { color: #9B8AAA !important; }
                .platform-admin-dashboard .text-slate-300 { color: #C9BFCE !important; }

                .platform-admin-dashboard .text-amber-900 { color: #78350F !important; }
                .platform-admin-dashboard .text-amber-800 { color: #8A5A00 !important; }
                .platform-admin-dashboard .text-amber-700 { color: #9A5A00 !important; }
                .platform-admin-dashboard .text-amber-600 { color: #B45309 !important; }
                .platform-admin-dashboard .text-emerald-950 { color: #14532D !important; }
                .platform-admin-dashboard .text-emerald-800 { color: #226B36 !important; }
                .platform-admin-dashboard .text-emerald-700 { color: #226B36 !important; }
                .platform-admin-dashboard .text-emerald-600 { color: #2F855A !important; }
                .platform-admin-dashboard .text-rose-950 { color: #881337 !important; }
                .platform-admin-dashboard .text-rose-800 { color: #9A2424 !important; }
                .platform-admin-dashboard .text-rose-700 { color: #B42318 !important; }
                .platform-admin-dashboard .text-rose-600 { color: #C2410C !important; }
                .platform-admin-dashboard .text-sky-600 { color: #2563EB !important; }
                .platform-admin-dashboard .text-violet-700 { color: #4B21BD !important; }

                .platform-admin-dashboard .adm-card,
                .platform-admin-dashboard [role="dialog"] {
                    background: #FFFFFF !important;
                    border-color: #E6DDF0 !important;
                    box-shadow: 0 6px 18px rgba(45, 27, 78, 0.05) !important;
                }

                .platform-admin-dashboard .adm-soft-surface { background: #FCFBFE !important; }
                .platform-admin-dashboard .adm-table-head { background: #FBFAFD !important; }
                .platform-admin-dashboard .adm-divider { border-color: #F0ECF5 !important; }
                .platform-admin-dashboard .adm-primary,
                .platform-admin-dashboard .adm-primary * {
                    background: #3B1B88 !important;
                    color: #FFFFFF !important;
                }

                .platform-admin-dashboard .adm-secondary {
                    background: #F2EDFF !important;
                    border-color: #E1D6FB !important;
                    color: #3B1B88 !important;
                }
                .platform-admin-dashboard .adm-secondary * { color: #3B1B88 !important; }
                .platform-admin-dashboard .adm-outline {
                    background: #FFFFFF !important;
                    border-color: #E6DDF0 !important;
                    color: #4C4556 !important;
                }
                .platform-admin-dashboard .adm-outline * { color: #4C4556 !important; }

                .platform-admin-dashboard .adm-summary-icon svg { color: inherit !important; }
                .platform-admin-dashboard .adm-icon-warning { background: #FFF4D8 !important; color: #8A5A00 !important; }
                .platform-admin-dashboard .adm-icon-success { background: #E6F6EA !important; color: #226B36 !important; }
                .platform-admin-dashboard .adm-icon-info { background: #E8F0FF !important; color: #1D4ED8 !important; }
                .platform-admin-dashboard .adm-icon-danger { background: #FFE8E8 !important; color: #B42318 !important; }

                .platform-admin-dashboard .adm-plan { border-width: 1px !important; }
                .platform-admin-dashboard .adm-plan-starter { background: #E6F6EA !important; border-color: #B7E5C2 !important; color: #226B36 !important; }
                .platform-admin-dashboard .adm-plan-business { background: #FFF4D8 !important; border-color: #F5D56B !important; color: #8A5A00 !important; }
                .platform-admin-dashboard .adm-plan-enterprise { background: #F0EAFE !important; border-color: #D8C6F4 !important; color: #6B32BE !important; }

                .platform-admin-dashboard .adm-status-pending { background: #FFF4D8 !important; box-shadow: inset 0 0 0 1px #E8B54A !important; color: #8A5A00 !important; }
                .platform-admin-dashboard .adm-status-approved { background: #E6F6EA !important; box-shadow: inset 0 0 0 1px #B7E5C2 !important; color: #226B36 !important; }
                .platform-admin-dashboard .adm-status-rejected { background: #FFE8E8 !important; box-shadow: inset 0 0 0 1px #F3B5B5 !important; color: #B42318 !important; }

                .platform-admin-dashboard .adm-plan-dot { display: inline-block; height: 8px; width: 8px; border-radius: 9999px; }
                .platform-admin-dashboard .adm-plan-dot-starter { background: #63B874 !important; }
                .platform-admin-dashboard .adm-plan-dot-business { background: #C9951A !important; }
                .platform-admin-dashboard .adm-plan-dot-enterprise { background: #3B1B88 !important; }
                .platform-admin-dashboard .adm-progress-track { background: #EEE8F8 !important; }
                .platform-admin-dashboard .adm-progress-starter { background: #63B874 !important; }
                .platform-admin-dashboard .adm-progress-business { background: #C9951A !important; }
                .platform-admin-dashboard .adm-progress-enterprise { background: #3B1B88 !important; }

                .platform-admin-dashboard article,
                .platform-admin-dashboard [role="dialog"] {
                    background: #FFFFFF !important;
                    border-color: #E6DDF0 !important;
                }

                .platform-admin-dashboard [class*="bg-white"] { background-color: #FFFFFF !important; }
                .platform-admin-dashboard [class*="bg-slate-50"] { background-color: #FCFBFE !important; }
                .platform-admin-dashboard [class*="bg-amber-50"] { background-color: #FFF4D8 !important; }
                .platform-admin-dashboard [class*="bg-amber-100"] { background-color: #FFF4D8 !important; }
                .platform-admin-dashboard [class*="bg-emerald-50"] { background-color: #E6F6EA !important; }
                .platform-admin-dashboard [class*="bg-emerald-100"] { background-color: #E6F6EA !important; }
                .platform-admin-dashboard [class*="bg-rose-50"] { background-color: #FFE8E8 !important; }
                .platform-admin-dashboard [class*="bg-rose-100"] { background-color: #FFE8E8 !important; }
                .platform-admin-dashboard [class*="bg-rose-500"] { background-color: #F05264 !important; }
                .platform-admin-dashboard [class*="bg-sky-100"] { background-color: #E8F0FF !important; }
                .platform-admin-dashboard [class*="bg-violet-50"] { background-color: #F0EAFE !important; }
                .platform-admin-dashboard [class*="bg-violet-100"] { background-color: #F0EAFE !important; }
                .platform-admin-dashboard [class*="bg-emerald-600"] { background-color: #2F855A !important; }
                .platform-admin-dashboard [class*="bg-rose-600"] { background-color: #B42318 !important; }
                .platform-admin-dashboard [class*="bg-[#FAF8FF]"] { background-color: #FCFBFE !important; }
                .platform-admin-dashboard [class*="bg-[#F2EDFF]"] { background-color: #F2EDFF !important; }
                .platform-admin-dashboard [class*="bg-[#EFE9FF]"] { background-color: #F0EAFE !important; }
                .platform-admin-dashboard [class*="bg-[#F0EAFE]"] { background-color: #F0EAFE !important; }
                .platform-admin-dashboard [class*="bg-[#FFF4D8]"] { background-color: #FFF4D8 !important; }
                .platform-admin-dashboard [class*="bg-[#FFF9E6]"] { background-color: #FFF9E6 !important; }
                .platform-admin-dashboard [class*="bg-[#FCFBFF]"] { background-color: #FCFBFE !important; }
                .platform-admin-dashboard [class*="bg-[#6D4FC2]"] { background-color: #3B1B88 !important; }
                .platform-admin-dashboard [class*="bg-[#593AAE]"] { background-color: #2B174C !important; }

                .platform-admin-dashboard [class*="bg-[#6D4FC2]"],
                .platform-admin-dashboard [class*="bg-[#593AAE]"],
                .platform-admin-dashboard [class*="bg-emerald-600"],
                .platform-admin-dashboard [class*="bg-rose-600"],
                .platform-admin-dashboard [class*="bg-rose-500"] {
                    color: #FFFFFF !important;
                }

                .platform-admin-dashboard .border-slate-100,
                .platform-admin-dashboard .divide-slate-100 > :not([hidden]) ~ :not([hidden]) {
                    border-color: #F0ECF5 !important;
                }
                .platform-admin-dashboard .border-slate-200 { border-color: #E6DDF0 !important; }
                .platform-admin-dashboard .border-amber-100,
                .platform-admin-dashboard .border-amber-200 { border-color: #F5D56B !important; }
                .platform-admin-dashboard .border-emerald-100 { border-color: #B7E5C2 !important; }
                .platform-admin-dashboard .border-rose-200 { border-color: #F3B5B5 !important; }
                .platform-admin-dashboard .border-violet-100 { border-color: #D8C6F4 !important; }
                .platform-admin-dashboard [class*="border-[#DCD2F8]"] { border-color: #D8C6F4 !important; }
                .platform-admin-dashboard [class*="border-[#E4DCF8]"] { border-color: #E1D6FB !important; }

                /* Compact desktop dashboard layout. These local rules keep the admin panels side by side and prevent oversized charts. */
                .platform-admin-dashboard .adm-dashboard-content {
                    width: 100% !important;
                    max-width: 1420px !important;
                    padding-bottom: 26px !important;
                }

                .platform-admin-dashboard .adm-primary-grid,
                .platform-admin-dashboard .adm-secondary-grid {
                    display: grid !important;
                    align-items: stretch !important;
                    gap: 16px !important;
                }

                .platform-admin-dashboard .adm-primary-grid {
                    grid-template-columns: minmax(0, 1.7fr) minmax(320px, 0.88fr) !important;
                }

                .platform-admin-dashboard .adm-secondary-grid {
                    grid-template-columns: minmax(0, 1.36fr) minmax(300px, 0.64fr) !important;
                }

                .platform-admin-dashboard .adm-compact-table th,
                .platform-admin-dashboard .adm-compact-table td {
                    padding-top: 10px !important;
                    padding-bottom: 10px !important;
                }

                .platform-admin-dashboard .adm-renewal-row {
                    padding: 11px 16px !important;
                }

                .platform-admin-dashboard .adm-revenue-card,
                .platform-admin-dashboard .adm-plan-mix-card {
                    min-height: 0 !important;
                }

                .platform-admin-dashboard .adm-revenue-chart {
                    height: 142px !important;
                    min-height: 142px !important;
                    max-height: 142px !important;
                    overflow: hidden !important;
                }

                .platform-admin-dashboard .adm-revenue-chart svg {
                    display: block !important;
                    height: 132px !important;
                    min-height: 0 !important;
                    max-height: 132px !important;
                    width: 100% !important;
                }

                .platform-admin-dashboard .adm-donut {
                    display: grid !important;
                    height: 118px !important;
                    width: 118px !important;
                    place-items: center !important;
                    border-radius: 9999px !important;
                    background: conic-gradient(#3B1B88 0deg 180deg, #C9951A 180deg 280deg, #63B874 280deg 360deg) !important;
                }

                .platform-admin-dashboard .adm-donut-center {
                    display: grid !important;
                    height: 78px !important;
                    width: 78px !important;
                    place-items: center !important;
                    border-radius: 9999px !important;
                    background: #FFFFFF !important;
                    text-align: center !important;
                }

                /* Final compact pass: match the denser dashboard reference without changing data or actions. */
                .platform-admin-dashboard .adm-dashboard-content {
                    max-width: 1600px !important;
                    padding: 18px 20px 22px !important;
                }

                .platform-admin-dashboard .adm-page-heading h2 {
                    font-size: 24px !important;
                    line-height: 1.15 !important;
                }

                .platform-admin-dashboard .adm-page-heading > div:first-child > p:last-child {
                    font-size: 12px !important;
                    margin-top: 5px !important;
                }

                .platform-admin-dashboard .adm-page-heading .adm-outline {
                    min-height: 36px !important;
                    padding: 8px 11px !important;
                    font-size: 12px !important;
                }

                .platform-admin-dashboard .adm-summary-grid {
                    gap: 12px !important;
                }

                .platform-admin-dashboard .adm-summary-grid .adm-card {
                    height: 88px !important;
                    min-height: 88px !important;
                    padding: 12px 14px !important;
                    border-radius: 13px !important;
                }

                .platform-admin-dashboard .adm-summary-grid .adm-title.text-xs {
                    font-size: 11px !important;
                }

                .platform-admin-dashboard .adm-summary-grid .adm-title.text-\[25px\] {
                    margin-top: 2px !important;
                    font-size: 23px !important;
                }

                .platform-admin-dashboard .adm-summary-grid .adm-muted {
                    margin-top: 3px !important;
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-summary-grid .adm-summary-icon {
                    height: 34px !important;
                    width: 34px !important;
                    border-radius: 11px !important;
                }

                .platform-admin-dashboard .adm-summary-grid .adm-summary-icon svg {
                    height: 18px !important;
                    width: 18px !important;
                }

                .platform-admin-dashboard .adm-primary-grid {
                    grid-template-columns: minmax(0, 1.72fr) minmax(330px, 0.88fr) !important;
                    gap: 14px !important;
                }

                .platform-admin-dashboard .adm-secondary-grid {
                    grid-template-columns: minmax(0, 1.44fr) minmax(320px, 0.76fr) !important;
                    gap: 14px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:first-child {
                    padding: 12px 16px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:first-child h3,
                .platform-admin-dashboard .adm-renewal-panel > div:first-child h3,
                .platform-admin-dashboard .adm-revenue-card h3,
                .platform-admin-dashboard .adm-plan-mix-card h3 {
                    font-size: 15px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:first-child p,
                .platform-admin-dashboard .adm-renewal-panel > div:first-child p,
                .platform-admin-dashboard .adm-revenue-card > div:first-child p,
                .platform-admin-dashboard .adm-plan-mix-card > div:first-child p {
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) {
                    padding: 8px 16px !important;
                    gap: 8px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) input,
                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) button {
                    height: 34px !important;
                    font-size: 11px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) input {
                    border-radius: 9px !important;
                }

                .platform-admin-dashboard .adm-compact-table {
                    min-width: 0 !important;
                    width: 100% !important;
                    table-layout: fixed !important;
                }

                .platform-admin-dashboard .adm-compact-table th,
                .platform-admin-dashboard .adm-compact-table td {
                    padding: 8px 10px !important;
                    vertical-align: middle !important;
                }

                .platform-admin-dashboard .adm-compact-table thead th {
                    font-size: 9px !important;
                    line-height: 1.1 !important;
                    white-space: nowrap !important;
                }

                /* Current-plan and reference-number data remain available in Review; they are hidden only in the compact overview. */
                .platform-admin-dashboard .adm-compact-table th:nth-child(2),
                .platform-admin-dashboard .adm-compact-table td:nth-child(2),
                .platform-admin-dashboard .adm-compact-table th:nth-child(5),
                .platform-admin-dashboard .adm-compact-table td:nth-child(5) {
                    display: none !important;
                }

                .platform-admin-dashboard .adm-compact-table th:nth-child(1),
                .platform-admin-dashboard .adm-compact-table td:nth-child(1) { width: 37% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(3),
                .platform-admin-dashboard .adm-compact-table td:nth-child(3) { width: 16% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(4),
                .platform-admin-dashboard .adm-compact-table td:nth-child(4) { width: 11% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(6),
                .platform-admin-dashboard .adm-compact-table td:nth-child(6) { width: 17% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(7),
                .platform-admin-dashboard .adm-compact-table td:nth-child(7) { width: 10% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(8),
                .platform-admin-dashboard .adm-compact-table td:nth-child(8) { width: 9% !important; }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) .h-9.w-9 {
                    height: 32px !important;
                    width: 32px !important;
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) > div {
                    gap: 9px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) p:first-child {
                    font-size: 12px !important;
                    line-height: 1.15 !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) p:last-child,
                .platform-admin-dashboard .adm-compact-table td:nth-child(6) {
                    font-size: 10px !important;
                    line-height: 1.25 !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(6) {
                    white-space: normal !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(4) {
                    font-size: 12px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(8) .adm-primary {
                    min-height: 31px !important;
                    padding: 6px 9px !important;
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(8) .adm-primary svg {
                    height: 13px !important;
                    width: 13px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel > div:first-child {
                    padding: 12px 16px !important;
                }

                .platform-admin-dashboard .adm-renewal-row {
                    min-height: 54px !important;
                    padding: 8px 16px !important;
                    gap: 9px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row > span:first-child {
                    height: 32px !important;
                    width: 32px !important;
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row p:first-child {
                    font-size: 12px !important;
                    line-height: 1.15 !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row p.mt-1 {
                    margin-top: 3px !important;
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row p.mt-1\.5 {
                    margin-top: 3px !important;
                    font-size: 9px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row .adm-plan {
                    padding: 3px 6px !important;
                    font-size: 9px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row > span:last-child {
                    padding: 5px 8px !important;
                    font-size: 9px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel > div:last-child {
                    margin: 10px 16px 14px !important;
                    padding: 9px 11px !important;
                    border-radius: 10px !important;
                }

                .platform-admin-dashboard .adm-renewal-panel > div:last-child p {
                    font-size: 10px !important;
                    line-height: 1.35 !important;
                }

                .platform-admin-dashboard .adm-revenue-card,
                .platform-admin-dashboard .adm-plan-mix-card {
                    min-height: 234px !important;
                    padding: 14px 16px !important;
                }

                .platform-admin-dashboard .adm-revenue-card .h-1,
                .platform-admin-dashboard .adm-plan-mix-card .h-1 {
                    margin-bottom: 6px !important;
                    height: 3px !important;
                }

                .platform-admin-dashboard .adm-revenue-card .mt-4 {
                    margin-top: 10px !important;
                }

                .platform-admin-dashboard .adm-revenue-card .adm-title.text-\[26px\] {
                    font-size: 21px !important;
                }

                .platform-admin-dashboard .adm-revenue-chart {
                    height: 106px !important;
                    min-height: 106px !important;
                    max-height: 106px !important;
                    padding: 7px 9px 0 !important;
                    border-radius: 10px !important;
                }

                .platform-admin-dashboard .adm-revenue-chart svg {
                    height: 98px !important;
                    min-height: 98px !important;
                    max-height: 98px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .mt-5 {
                    margin-top: 12px !important;
                }

                .platform-admin-dashboard .adm-donut {
                    height: 94px !important;
                    width: 94px !important;
                }

                .platform-admin-dashboard .adm-donut-center {
                    height: 62px !important;
                    width: 62px !important;
                }

                .platform-admin-dashboard .adm-donut-center .text-2xl {
                    font-size: 19px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .space-y-3 > :not([hidden]) ~ :not([hidden]) {
                    margin-top: 8px !important;
                }

                @media (max-width: 1180px) {
                    .platform-admin-dashboard .adm-primary-grid,
                    .platform-admin-dashboard .adm-secondary-grid {
                        grid-template-columns: minmax(0, 1fr) !important;
                    }
                }

                .platform-admin-dashboard input,
                .platform-admin-dashboard select {
                    background: #FFFFFF !important;
                    border-color: #E6DDF0 !important;
                    color: #1A1220 !important;
                    color-scheme: light !important;
                }
                .platform-admin-dashboard input::placeholder {
                    color: #9B8AAA !important;
                    opacity: 1 !important;
                }


                /* Refinement: keep the verification table dense and prevent the first panel from stretching to the renewal panel height. */
                .platform-admin-dashboard .adm-primary-grid {
                    align-items: start !important;
                }

                .platform-admin-dashboard .adm-payment-panel {
                    align-self: start !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:first-child {
                    padding: 10px 16px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) {
                    padding: 7px 16px !important;
                }

                .platform-admin-dashboard .adm-compact-table th,
                .platform-admin-dashboard .adm-compact-table td {
                    padding-top: 7px !important;
                    padding-bottom: 7px !important;
                }

                .platform-admin-dashboard .adm-compact-table tbody tr {
                    height: 52px !important;
                }

                .platform-admin-dashboard .adm-compact-table th:nth-child(1),
                .platform-admin-dashboard .adm-compact-table td:nth-child(1) { width: 36% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(3),
                .platform-admin-dashboard .adm-compact-table td:nth-child(3) { width: 15% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(4),
                .platform-admin-dashboard .adm-compact-table td:nth-child(4) { width: 10% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(6),
                .platform-admin-dashboard .adm-compact-table td:nth-child(6) { width: 18% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(7),
                .platform-admin-dashboard .adm-compact-table td:nth-child(7) { width: 10% !important; }
                .platform-admin-dashboard .adm-compact-table th:nth-child(8),
                .platform-admin-dashboard .adm-compact-table td:nth-child(8) { width: 11% !important; }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) .h-9.w-9 {
                    height: 30px !important;
                    width: 30px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) p:first-child {
                    font-size: 11px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(1) p:last-child,
                .platform-admin-dashboard .adm-compact-table td:nth-child(6) {
                    font-size: 9px !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(6) {
                    white-space: nowrap !important;
                }

                .platform-admin-dashboard .adm-compact-table td:nth-child(8) .adm-primary {
                    min-width: 72px !important;
                    min-height: 29px !important;
                    justify-content: center !important;
                    padding: 5px 8px !important;
                    white-space: nowrap !important;
                }

                /* A slightly larger plan donut improves the balance of the compact summary card. */
                .platform-admin-dashboard .adm-plan-mix-card {
                    min-height: 250px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .mt-5 {
                    margin-top: 14px !important;
                }

                .platform-admin-dashboard .adm-donut {
                    height: 118px !important;
                    width: 118px !important;
                }

                .platform-admin-dashboard .adm-donut-center {
                    height: 76px !important;
                    width: 76px !important;
                }

                .platform-admin-dashboard .adm-donut-center .text-2xl {
                    font-size: 22px !important;
                }

                @media (max-width: 1180px) {
                    .platform-admin-dashboard .adm-primary-grid {
                        align-items: stretch !important;
                    }
                }


                /* Final balance pass: use six real table columns so every header matches its data column. */
                .platform-admin-dashboard .adm-payment-panel {
                    min-height: 0 !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:first-child {
                    padding: 12px 16px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) {
                    padding: 9px 16px !important;
                }

                .platform-admin-dashboard .adm-payment-table {
                    table-layout: fixed !important;
                    border-collapse: collapse !important;
                }

                .platform-admin-dashboard .adm-payment-table th {
                    padding: 10px 12px !important;
                    white-space: nowrap !important;
                    font-size: 9px !important;
                    line-height: 1.15 !important;
                }

                .platform-admin-dashboard .adm-payment-table td {
                    padding: 9px 12px !important;
                    vertical-align: middle !important;
                }

                .platform-admin-dashboard .adm-payment-table th:first-child,
                .platform-admin-dashboard .adm-payment-table td:first-child {
                    padding-left: 16px !important;
                }

                .platform-admin-dashboard .adm-payment-table th:last-child,
                .platform-admin-dashboard .adm-payment-table td:last-child {
                    padding-right: 14px !important;
                }

                .platform-admin-dashboard .adm-payment-table tbody tr {
                    height: 56px !important;
                }

                .platform-admin-dashboard .adm-payment-table .adm-plan {
                    padding: 4px 8px !important;
                    font-size: 9px !important;
                    white-space: nowrap !important;
                }

                .platform-admin-dashboard .adm-payment-table .adm-status {
                    padding: 4px 9px !important;
                    font-size: 9px !important;
                    white-space: nowrap !important;
                }

                /* Restore a useful chart area; only the pie chart is enlarged. */
                .platform-admin-dashboard .adm-revenue-card,
                .platform-admin-dashboard .adm-plan-mix-card {
                    min-height: 344px !important;
                }

                .platform-admin-dashboard .adm-revenue-chart {
                    height: 192px !important;
                    min-height: 192px !important;
                    max-height: 192px !important;
                    padding: 8px 10px 0 !important;
                }

                .platform-admin-dashboard .adm-revenue-chart svg {
                    height: 184px !important;
                    min-height: 184px !important;
                    max-height: 184px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .mt-5 {
                    margin-top: 18px !important;
                }

                .platform-admin-dashboard .adm-donut {
                    height: 132px !important;
                    width: 132px !important;
                }

                .platform-admin-dashboard .adm-donut-center {
                    height: 84px !important;
                    width: 84px !important;
                }

                .platform-admin-dashboard .adm-donut-center .text-2xl {
                    font-size: 24px !important;
                }

                @media (max-width: 680px) {
                    .platform-admin-dashboard .adm-payment-table th,
                    .platform-admin-dashboard .adm-payment-table td {
                        padding-left: 7px !important;
                        padding-right: 7px !important;
                    }

                    .platform-admin-dashboard .adm-payment-table th:first-child,
                    .platform-admin-dashboard .adm-payment-table td:first-child {
                        padding-left: 10px !important;
                    }

                    .platform-admin-dashboard .adm-payment-table td:nth-child(4) {
                        white-space: normal !important;
                    }
                }

                /* Payment Verification compact content pass. */
                .platform-admin-dashboard .adm-payment-panel > div:first-child {
                    padding: 9px 14px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) {
                    padding: 6px 14px !important;
                    gap: 7px !important;
                }

                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) input,
                .platform-admin-dashboard .adm-payment-panel > div:nth-child(2) button {
                    height: 34px !important;
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-payment-table {
                    width: 100% !important;
                    table-layout: fixed !important;
                    border-collapse: collapse !important;
                }

                .platform-admin-dashboard .adm-payment-table th {
                    padding: 7px 10px !important;
                    font-size: 8px !important;
                    line-height: 1 !important;
                    white-space: nowrap !important;
                }

                .platform-admin-dashboard .adm-payment-table td {
                    padding: 5px 10px !important;
                    vertical-align: middle !important;
                }

                .platform-admin-dashboard .adm-payment-table tbody tr {
                    height: 44px !important;
                }

                .platform-admin-dashboard .adm-payment-table th:first-child,
                .platform-admin-dashboard .adm-payment-table td:first-child {
                    padding-left: 14px !important;
                }

                .platform-admin-dashboard .adm-payment-table th:last-child,
                .platform-admin-dashboard .adm-payment-table td:last-child {
                    padding-right: 10px !important;
                }

                .platform-admin-dashboard .adm-payment-table th:nth-child(2),
                .platform-admin-dashboard .adm-payment-table td:nth-child(2),
                .platform-admin-dashboard .adm-payment-table th:nth-child(3),
                .platform-admin-dashboard .adm-payment-table td:nth-child(3),
                .platform-admin-dashboard .adm-payment-table th:nth-child(4),
                .platform-admin-dashboard .adm-payment-table td:nth-child(4),
                .platform-admin-dashboard .adm-payment-table th:nth-child(5),
                .platform-admin-dashboard .adm-payment-table td:nth-child(5),
                .platform-admin-dashboard .adm-payment-table th:nth-child(6),
                .platform-admin-dashboard .adm-payment-table td:nth-child(6) {
                    text-align: center !important;
                }

                .platform-admin-dashboard .adm-payment-table td:first-child > div {
                    gap: 7px !important;
                }

                .platform-admin-dashboard .adm-payment-table td:first-child .h-8.w-8 {
                    height: 28px !important;
                    width: 28px !important;
                    font-size: 9px !important;
                }

                .platform-admin-dashboard .adm-payment-table td:first-child p:first-child {
                    font-size: 11px !important;
                    line-height: 1.05 !important;
                }

                .platform-admin-dashboard .adm-payment-table td:first-child p:last-child {
                    margin-top: 1px !important;
                    font-size: 9px !important;
                    line-height: 1.05 !important;
                }

                .platform-admin-dashboard .adm-payment-table .adm-plan {
                    padding: 3px 7px !important;
                    font-size: 8px !important;
                    line-height: 1.1 !important;
                }

                .platform-admin-dashboard .adm-payment-table .adm-status {
                    padding: 3px 8px !important;
                    font-size: 8px !important;
                    line-height: 1.1 !important;
                }

                .platform-admin-dashboard .adm-payment-table td:nth-child(3) {
                    font-size: 11px !important;
                    white-space: nowrap !important;
                }

                .platform-admin-dashboard .adm-payment-table td:nth-child(4) {
                    font-size: 9px !important;
                    white-space: nowrap !important;
                }

                .platform-admin-dashboard .adm-payment-table td:nth-child(6) .adm-primary {
                    min-width: 66px !important;
                    min-height: 27px !important;
                    padding: 4px 7px !important;
                    font-size: 9px !important;
                    line-height: 1 !important;
                }

                .platform-admin-dashboard .adm-payment-table td:nth-child(6) .adm-primary svg {
                    height: 12px !important;
                    width: 12px !important;
                }



                /* Final UI polish: center store initials inside circles and expand the revenue section upward. */
                .platform-admin-dashboard .adm-payment-table td:first-child .h-8.w-8,
                .platform-admin-dashboard .adm-renewal-row > span:first-child {
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    padding: 0 !important;
                    line-height: 1 !important;
                    text-align: center !important;
                }

                .platform-admin-dashboard .adm-payment-table td:first-child .h-8.w-8 {
                    font-size: 10px !important;
                }

                .platform-admin-dashboard .adm-payment-table td:first-child .h-8.w-8,
                .platform-admin-dashboard .adm-renewal-row > span:first-child {
                    vertical-align: middle !important;
                }

                .platform-admin-dashboard .adm-revenue-card {
                    min-height: 438px !important;
                }

                .platform-admin-dashboard .adm-revenue-chart {
                    height: 282px !important;
                    min-height: 282px !important;
                    max-height: 282px !important;
                    padding-top: 2px !important;
                }

                .platform-admin-dashboard .adm-revenue-chart svg {
                    height: 274px !important;
                    min-height: 274px !important;
                    max-height: 274px !important;
                }



                /* Keep row dividers soft. This overrides the project-wide dark table borders. */
                .platform-admin-dashboard .adm-payment-table tbody tr,
                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row {
                    border-top-color: transparent !important;
                    border-bottom-color: transparent !important;
                }

                .platform-admin-dashboard .adm-payment-table tbody tr + tr td {
                    border-top: 1px solid #F0ECF5 !important;
                }

                .platform-admin-dashboard .adm-renewal-panel .adm-renewal-row + .adm-renewal-row {
                    border-top: 1px solid #F0ECF5 !important;
                }



                /* Desktop layout: place Subscription Revenue directly below Payment Verification. */
                @media (min-width: 1181px) {
                    .platform-admin-dashboard .adm-revenue-card {
                        margin-top: -108px !important;
                    }
                }



                /* Keep the Subscriptions by Plan card compact instead of stretching to the revenue-card height. */
                .platform-admin-dashboard .adm-secondary-grid {
                    align-items: start !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card {
                    align-self: start !important;
                    min-height: 0 !important;
                    height: 228px !important;
                    padding: 14px 16px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .mt-5 {
                    margin-top: 10px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .mt-5.flex {
                    gap: 18px !important;
                    justify-content: flex-start !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .w-full.max-w-\[230px\] {
                    max-width: 188px !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card .space-y-3 > :not([hidden]) ~ :not([hidden]) {
                    margin-top: 7px !important;
                }

                @media (max-width: 640px) {
                    .platform-admin-dashboard .adm-plan-mix-card {
                        height: auto !important;
                    }

                    .platform-admin-dashboard .adm-plan-mix-card .mt-5.flex {
                        align-items: center !important;
                    }
                }



                /* Center the summary icons inside their colored boxes. */
                .platform-admin-dashboard .adm-summary-icon {
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    align-self: center !important;
                    padding: 0 !important;
                    line-height: 1 !important;
                }

                .platform-admin-dashboard .adm-summary-icon svg {
                    display: block !important;
                    margin: 0 !important;
                    flex: 0 0 auto !important;
                }



                /* Payment review dialog: compact surface with a soft blurred dashboard backdrop. */
                .platform-admin-dashboard .adm-review-layer {
                    z-index: 70 !important;
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    padding: 18px !important;
                }

                .platform-admin-dashboard .adm-review-backdrop {
                    background: rgba(43, 23, 76, 0.20) !important;
                    backdrop-filter: blur(9px) saturate(0.92) !important;
                    -webkit-backdrop-filter: blur(9px) saturate(0.92) !important;
                }

                .platform-admin-dashboard .adm-review-dialog {
                    width: min(100%, 880px) !important;
                    max-width: 880px !important;
                    max-height: min(86vh, 760px) !important;
                    overflow-y: auto !important;
                    border: 1px solid #E6DDF0 !important;
                    border-radius: 18px !important;
                    background: #FFFFFF !important;
                    box-shadow: 0 24px 70px rgba(43, 23, 76, 0.22) !important;
                }

                .platform-admin-dashboard .adm-review-header {
                    position: sticky !important;
                    top: 0 !important;
                    z-index: 3 !important;
                    padding: 16px 18px !important;
                    border-bottom: 1px solid #F0ECF5 !important;
                    background: rgba(255, 255, 255, 0.97) !important;
                    backdrop-filter: blur(10px) !important;
                }

                .platform-admin-dashboard .adm-review-body {
                    display: grid !important;
                    grid-template-columns: minmax(0, 1fr) minmax(250px, 0.82fr) !important;
                    gap: 14px !important;
                    padding: 16px 18px !important;
                }

                .platform-admin-dashboard .adm-review-card {
                    border: 1px solid #E6DDF0 !important;
                    border-radius: 13px !important;
                    background: #FFFFFF !important;
                    padding: 13px !important;
                }

                .platform-admin-dashboard .adm-review-proof {
                    display: grid !important;
                    min-height: 190px !important;
                    place-items: center !important;
                    border: 1.5px dashed #D8C6F4 !important;
                    border-radius: 13px !important;
                    background: #FCFBFE !important;
                    padding: 18px !important;
                    text-align: center !important;
                }

                .platform-admin-dashboard .adm-review-actions {
                    position: sticky !important;
                    bottom: 0 !important;
                    z-index: 3 !important;
                    padding: 13px 18px !important;
                    border-top: 1px solid #F0ECF5 !important;
                    background: rgba(255, 255, 255, 0.97) !important;
                    backdrop-filter: blur(10px) !important;
                }

                .platform-admin-dashboard .adm-review-warning {
                    border: 1px solid #F5D56B !important;
                    border-radius: 12px !important;
                    background: #FFF9E6 !important;
                    padding: 11px 12px !important;
                }

                @media (max-width: 760px) {
                    .platform-admin-dashboard .adm-review-layer {
                        align-items: flex-end !important;
                        padding: 10px !important;
                    }

                    .platform-admin-dashboard .adm-review-dialog {
                        max-height: 91vh !important;
                        border-radius: 16px !important;
                    }

                    .platform-admin-dashboard .adm-review-body {
                        grid-template-columns: minmax(0, 1fr) !important;
                        padding: 14px !important;
                    }

                    .platform-admin-dashboard .adm-review-header,
                    .platform-admin-dashboard .adm-review-actions {
                        padding-left: 14px !important;
                        padding-right: 14px !important;
                    }
                }



                .platform-admin-dashboard .adm-right-stack {
                    display: flex !important;
                    min-width: 0 !important;
                    flex-direction: column !important;
                    gap: 14px !important;
                }

                .platform-admin-dashboard .adm-qr-card {
                    min-height: 214px !important;
                }

                .platform-admin-dashboard .adm-qr-box {
                    display: grid !important;
                    height: 132px !important;
                    width: 132px !important;
                    place-items: center !important;
                    border-radius: 18px !important;
                    border: 1px solid #E6DDF0 !important;
                    background: linear-gradient(180deg, #FFFFFF 0%, #FCFBFE 100%) !important;
                    padding: 10px !important;
                    box-shadow: 0 4px 14px rgba(45, 27, 78, 0.06) !important;
                }

                .platform-admin-dashboard .adm-qr-badge {
                    display: inline-flex !important;
                    align-items: center !important;
                    gap: 6px !important;
                    border-radius: 9999px !important;
                    border: 1px solid #E1D6FB !important;
                    background: #F2EDFF !important;
                    padding: 6px 10px !important;
                    color: #3B1B88 !important;
                    font-size: 11px !important;
                    font-weight: 700 !important;
                }

                @media (max-width: 1180px) {
                    .platform-admin-dashboard .adm-right-stack {
                        gap: 12px !important;
                    }
                }

                /* Keep the revenue card aligned with the full right-side stack.
                   The plan card stays exactly the same size. */
                @media (min-width: 1181px) {
                    .platform-admin-dashboard .adm-revenue-card {
                        min-height: 646px !important;
                    }

                    .platform-admin-dashboard .adm-revenue-chart {
                        height: 432px !important;
                        min-height: 432px !important;
                        max-height: 432px !important;
                    }

                    .platform-admin-dashboard .adm-revenue-chart svg {
                        height: 424px !important;
                        min-height: 424px !important;
                        max-height: 424px !important;
                    }
                }



                /* Final layout alignment: the revenue card ends on the same line as the QR Payment card.
                   The plan card is enlarged slightly so it does not look undersized beside the QR card. */
                @media (min-width: 1181px) {
                    .platform-admin-dashboard .adm-plan-mix-card {
                        height: 260px !important;
                        min-height: 260px !important;
                        max-height: 260px !important;
                    }

                    .platform-admin-dashboard .adm-qr-card {
                        height: 260px !important;
                        min-height: 260px !important;
                        max-height: 260px !important;
                    }

                    .platform-admin-dashboard .adm-plan-mix-card .mt-5 {
                        margin-top: 14px !important;
                    }

                    .platform-admin-dashboard .adm-donut {
                        height: 140px !important;
                        width: 140px !important;
                    }

                    .platform-admin-dashboard .adm-donut-center {
                        height: 88px !important;
                        width: 88px !important;
                    }

                    .platform-admin-dashboard .adm-revenue-card {
                        height: 652px !important;
                        min-height: 652px !important;
                        max-height: 652px !important;
                    }

                    .platform-admin-dashboard .adm-revenue-chart {
                        height: 416px !important;
                        min-height: 416px !important;
                        max-height: 416px !important;
                    }

                    .platform-admin-dashboard .adm-revenue-chart svg {
                        height: 408px !important;
                        min-height: 408px !important;
                        max-height: 408px !important;
                    }
                }



                /* Keep the two right-side cards the same horizontal width. */
                .platform-admin-dashboard .adm-right-stack {
                    width: 100% !important;
                }

                .platform-admin-dashboard .adm-right-stack > .adm-card {
                    width: 100% !important;
                    align-self: stretch !important;
                    box-sizing: border-box !important;
                }

                .platform-admin-dashboard .adm-plan-mix-card {
                    align-self: stretch !important;
                }



                /* Platform payment settings and logout controls. */
                .platform-admin-dashboard .adm-logout-button {
                    display: inline-flex !important;
                    height: 40px !important;
                    align-items: center !important;
                    justify-content: center !important;
                    gap: 7px !important;
                    border: 1px solid #F1C1C1 !important;
                    border-radius: 9px !important;
                    background: #FFF7F7 !important;
                    padding: 0 12px !important;
                    color: #B42318 !important;
                    font-size: 12px !important;
                    font-weight: 700 !important;
                    transition: background 160ms ease, border-color 160ms ease !important;
                }

                .platform-admin-dashboard .adm-logout-button:hover {
                    border-color: #E9A6A6 !important;
                    background: #FFEAEA !important;
                }

                .platform-admin-dashboard .adm-logout-button svg {
                    color: #B42318 !important;
                }

                .platform-admin-dashboard .adm-qr-actions {
                    display: flex !important;
                    flex-wrap: wrap !important;
                    align-items: center !important;
                    justify-content: flex-end !important;
                    gap: 8px !important;
                }

                .platform-admin-dashboard .adm-qr-edit {
                    display: inline-flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    gap: 6px !important;
                    border: 1px solid #E1D6FB !important;
                    border-radius: 8px !important;
                    background: #FFFFFF !important;
                    padding: 6px 9px !important;
                    color: #3B1B88 !important;
                    font-size: 10px !important;
                    font-weight: 700 !important;
                    transition: background 160ms ease !important;
                }

                .platform-admin-dashboard .adm-qr-edit:hover {
                    background: #F2EDFF !important;
                }

                .platform-admin-dashboard .adm-qr-edit svg {
                    color: #3B1B88 !important;
                }

                .platform-admin-dashboard .adm-qr-image {
                    display: block !important;
                    height: 100% !important;
                    width: 100% !important;
                    object-fit: contain !important;
                    image-rendering: pixelated !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-layer {
                    z-index: 70 !important;
                    padding: 20px !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-backdrop {
                    background: rgba(26, 18, 32, 0.42) !important;
                    backdrop-filter: blur(6px) !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-dialog {
                    position: relative !important;
                    width: min(100%, 640px) !important;
                    max-height: min(88vh, 690px) !important;
                    overflow-y: auto !important;
                    border: 1px solid #E6DDF0 !important;
                    border-radius: 18px !important;
                    background: #FFFFFF !important;
                    box-shadow: 0 24px 80px rgba(33, 18, 59, 0.28) !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-header {
                    display: flex !important;
                    align-items: flex-start !important;
                    justify-content: space-between !important;
                    gap: 16px !important;
                    border-bottom: 1px solid #F0ECF5 !important;
                    padding: 18px 20px !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-body {
                    display: grid !important;
                    grid-template-columns: 170px minmax(0, 1fr) !important;
                    gap: 20px !important;
                    padding: 20px !important;
                }

                .platform-admin-dashboard .adm-gcash-preview {
                    display: flex !important;
                    min-height: 170px !important;
                    flex-direction: column !important;
                    align-items: center !important;
                    justify-content: center !important;
                    gap: 10px !important;
                    border: 1px dashed #D8C6F4 !important;
                    border-radius: 14px !important;
                    background: #FCFBFE !important;
                    padding: 14px !important;
                }

                .platform-admin-dashboard .adm-gcash-preview-image {
                    height: 104px !important;
                    width: 104px !important;
                    border: 1px solid #E6DDF0 !important;
                    border-radius: 12px !important;
                    background: #FFFFFF !important;
                    object-fit: contain !important;
                    padding: 8px !important;
                    image-rendering: pixelated !important;
                }

                .platform-admin-dashboard .adm-gcash-upload {
                    display: inline-flex !important;
                    cursor: pointer !important;
                    align-items: center !important;
                    justify-content: center !important;
                    gap: 6px !important;
                    border: 1px solid #E1D6FB !important;
                    border-radius: 8px !important;
                    background: #FFFFFF !important;
                    padding: 7px 9px !important;
                    color: #3B1B88 !important;
                    font-size: 10px !important;
                    font-weight: 700 !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-form {
                    display: grid !important;
                    gap: 13px !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-form label {
                    display: grid !important;
                    gap: 6px !important;
                    color: #4C4556 !important;
                    font-size: 11px !important;
                    font-weight: 700 !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-form input {
                    height: 40px !important;
                    border: 1px solid #E6DDF0 !important;
                    border-radius: 9px !important;
                    background: #FFFFFF !important;
                    padding: 0 11px !important;
                    color: #1A1220 !important;
                    font-size: 12px !important;
                    outline: none !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-form input:focus {
                    border-color: #BDA7EC !important;
                    box-shadow: 0 0 0 3px #F2EDFF !important;
                }

                .platform-admin-dashboard .adm-gcash-settings-footer {
                    display: flex !important;
                    justify-content: flex-end !important;
                    gap: 9px !important;
                    border-top: 1px solid #F0ECF5 !important;
                    padding: 14px 20px !important;
                }

                @media (max-width: 620px) {
                    .platform-admin-dashboard .adm-gcash-settings-layer {
                        padding: 10px !important;
                    }

                    .platform-admin-dashboard .adm-gcash-settings-body {
                        grid-template-columns: minmax(0, 1fr) !important;
                    }

                    .platform-admin-dashboard .adm-gcash-preview {
                        min-height: 150px !important;
                    }
                }

            `}</style>
            <section className="adm-dashboard-content mx-auto">
                <section className="adm-page-heading flex flex-col gap-3 xl:flex-row xl:items-end xl:justify-between">
                    <div>
                        <p className="adm-label text-[11px] font-bold uppercase tracking-[0.12em]">
                            Platform overview
                        </p>
                        <h2 className="adm-title mt-1 text-[27px] font-bold tracking-[-0.03em]">
                            Subscription Administration
                        </h2>
                        <p className="adm-muted mt-1.5 text-sm">
                            Review subscription payments and keep store access up to date.
                        </p>
                    </div>

                    <div className="flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            className="adm-outline inline-flex items-center gap-2 rounded-[9px] border px-3.5 py-2.5 text-sm font-semibold shadow-sm transition hover:bg-[#FCFBFE]"
                        >
                            <CalendarDays size={16} />
                            June 1 - June 26, 2026
                            <ChevronDown size={15} />
                        </button>
                        <button
                            type="button"
                            onClick={handleLogout}
                            className="adm-logout-button"
                        >
                            <LogOut size={15} />
                            Logout
                        </button>
                        <button
                            type="button"
                            aria-label="Refresh dashboard"
                            className="adm-outline grid h-10 w-10 place-items-center rounded-[9px] border shadow-sm transition hover:bg-[#FCFBFE]"
                        >
                            <RefreshCw size={17} />
                        </button>
                    </div>
                </section>

                <section className="adm-summary-grid mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                    <SummaryCard
                        title="Pending Verification"
                        value={pendingCount}
                        helper="Payments awaiting review"
                        icon={<Clock3 size={19} />}
                        iconClass="adm-icon-warning"
                    />
                    <SummaryCard
                        title="Active Subscriptions"
                        value="18"
                        helper="Businesses with active access"
                        icon={<CheckCircle2 size={19} />}
                        iconClass="adm-icon-success"
                    />
                    <SummaryCard
                        title="Expiring Soon"
                        value="4"
                        helper="Within the next 7 days"
                        icon={<CalendarDays size={19} />}
                        iconClass="adm-icon-info"
                    />
                    <SummaryCard
                        title="Expired Subscriptions"
                        value="2"
                        helper="Need renewal or review"
                        icon={<CircleAlert size={19} />}
                        iconClass="adm-icon-danger"
                    />
                </section>

                <section className="adm-primary-grid mt-4">
                    <article className="adm-card adm-payment-panel overflow-hidden rounded-[16px] border">
                        <div className="adm-divider flex flex-col gap-3 border-b px-5 py-4 lg:flex-row lg:items-center lg:justify-between">
                            <div className="min-w-0">
                                <div className="flex items-center gap-2">
                                    <h3 className="adm-title text-[17px] font-bold">Payment Verification</h3>
                                </div>
                                <p className="adm-muted mt-1 text-xs">
                                    Review the GCash proof before activating the requested subscription.
                                </p>
                            </div>

                            <Link
                                href="/platform-admin/subscriptions/pending"
                                className="adm-secondary inline-flex shrink-0 items-center justify-center gap-1.5 rounded-lg border px-3 py-2 text-xs font-semibold transition hover:bg-[#EAE2FA]"
                            >
                                View all
                                <ArrowUpRight size={14} />
                            </Link>
                        </div>

                        <div className="adm-divider flex flex-col gap-2 border-b px-5 py-3 sm:flex-row sm:items-center sm:justify-between">
                            <div className="relative w-full sm:max-w-sm">
                                <Search
                                    size={16}
                                    className="adm-muted pointer-events-none absolute left-3 top-1/2 -translate-y-1/2"
                                />
                                <input
                                    value={searchQuery}
                                    onChange={(event) => setSearchQuery(event.target.value)}
                                    placeholder="Search store, owner, or reference number"
                                    className="h-10 w-full rounded-[9px] border bg-white pl-9 pr-3 text-sm outline-none transition focus:border-[#CDBBF2] focus:ring-4 focus:ring-[#F2EDFF]"
                                />
                            </div>
                            <button
                                type="button"
                                className="adm-outline inline-flex h-10 shrink-0 items-center justify-center gap-2 rounded-[9px] border px-3 text-xs font-semibold transition hover:bg-[#FCFBFE]"
                            >
                                <Filter size={15} />
                                Filters
                            </button>
                        </div>

                        <div className="overflow-hidden">
                            <table className="adm-payment-table w-full table-fixed text-left">
                                <colgroup>
                                    <col className="w-[33%]" />
                                    <col className="w-[14%]" />
                                    <col className="w-[10%]" />
                                    <col className="w-[19%]" />
                                    <col className="w-[11%]" />
                                    <col className="w-[13%]" />
                                </colgroup>
                                <thead className="adm-table-head text-[9px] font-bold uppercase tracking-wide">
                                <tr>
                                    <th>Store / Owner</th>
                                    <th>Requested Plan</th>
                                    <th>Amount</th>
                                    <th>Submitted</th>
                                    <th>Status</th>
                                    <th className="text-center">Action</th>
                                </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-100">
                                {filteredPayments.length > 0 ? (
                                    filteredPayments.map((payment) => (
                                        <tr key={payment.id} className="transition hover:bg-[#FCFBFE]">
                                            <td>
                                                <div className="flex min-w-0 items-center gap-2.5">
                                                        <span className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-[#F0EAFE] text-[10px] font-bold text-[#3B1B88]">
                                                            {payment.storeName
                                                                .split(" ")
                                                                .slice(0, 2)
                                                                .map((word) => word[0])
                                                                .join("")}
                                                        </span>
                                                    <div className="min-w-0">
                                                        <p className="adm-title truncate text-[12px] font-semibold">
                                                            {payment.storeName}
                                                        </p>
                                                        <p className="adm-muted mt-0.5 truncate text-[10px]">
                                                            {payment.ownerName} · {payment.ownerEmail}
                                                        </p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><PlanBadge plan={payment.requestedPlan} /></td>
                                            <td className="adm-title text-[12px] font-bold">
                                                {currency.format(payment.amount)}
                                            </td>
                                            <td className="adm-muted whitespace-nowrap text-[10px]">
                                                {payment.submittedAt}
                                            </td>
                                            <td><PaymentStatusBadge status={payment.status} /></td>
                                            <td className="text-center">
                                                <button
                                                    type="button"
                                                    onClick={() => openPaymentReview(payment)}
                                                    className="adm-primary inline-flex min-w-[72px] items-center justify-center gap-1.5 rounded-lg px-2.5 py-1.5 text-[10px] font-bold shadow-sm transition hover:brightness-95"
                                                >
                                                    <Eye size={13} />
                                                    Review
                                                </button>
                                            </td>
                                        </tr>
                                    ))
                                ) : (
                                    <tr>
                                        <td colSpan={6} className="px-5 py-10 text-center">
                                            <Search className="adm-muted mx-auto" size={26} />
                                            <p className="adm-title mt-3 text-sm font-semibold">No payment requests found</p>
                                            <p className="adm-muted mt-1 text-xs">
                                                Try another store, owner, or reference number.
                                            </p>
                                        </td>
                                    </tr>
                                )}
                                </tbody>
                            </table>
                        </div>
                    </article>

                    <article className="adm-card adm-renewal-panel overflow-hidden rounded-[16px] border">
                        <div className="adm-divider flex items-start justify-between gap-3 border-b px-5 py-4">
                            <div>
                                <div className="mb-2 h-1 w-8 rounded-full bg-[#C9951A]" />
                                <h3 className="adm-title text-[17px] font-bold">Renewal Watch</h3>
                                <p className="adm-muted mt-1 text-xs">Stores approaching their expiration date.</p>
                            </div>
                            <Link
                                href="/platform-admin/subscriptions/expiring"
                                className="adm-accent shrink-0 text-xs font-semibold transition hover:underline"
                            >
                                View all →
                            </Link>
                        </div>

                        <div className="divide-y divide-slate-100">
                            {expiringSubscriptions.map((subscription, index) => (
                                <div key={subscription.storeName} className="adm-renewal-row flex items-center gap-3">
                                    <span
                                        className={`grid h-9 w-9 shrink-0 place-items-center rounded-full text-[11px] font-bold ${
                                            index % 2 === 0
                                                ? "bg-[#F0EAFE] text-[#3B1B88]"
                                                : "bg-[#FFF4D8] text-[#8A5A00]"
                                        }`}
                                    >
                                        {subscription.initials}
                                    </span>
                                    <div className="min-w-0 flex-1">
                                        <div className="flex flex-wrap items-center gap-2">
                                            <p className="adm-title truncate text-sm font-semibold">{subscription.storeName}</p>
                                            <PlanBadge plan={subscription.plan} />
                                        </div>
                                        <p className="adm-muted mt-1 truncate text-xs">{subscription.ownerEmail}</p>
                                        <p className="adm-muted mt-1.5 text-[11px]">Expires {subscription.expirationDate}</p>
                                    </div>
                                    <span
                                        className={`shrink-0 rounded-full px-2.5 py-1 text-[10px] font-bold ${
                                            subscription.daysLeft <= 3
                                                ? "adm-status-rejected"
                                                : "adm-status-pending"
                                        }`}
                                    >
                                        {subscription.daysLeft}d left
                                    </span>
                                </div>
                            ))}
                        </div>

                        <div className="mx-5 mb-5 mt-4 rounded-xl border border-[#F5D56B] bg-[#FFF9E6] px-3.5 py-3">
                            <div className="flex gap-2.5">
                                <ShieldAlert size={16} className="adm-warning mt-0.5 shrink-0" />
                                <p className="adm-warning text-xs leading-5">
                                    Reminders are scheduled at 7 days, 3 days, and on the expiration date.
                                </p>
                            </div>
                        </div>
                    </article>
                </section>

                <section className="adm-secondary-grid mt-4">
                    <article className="adm-card adm-revenue-card rounded-[16px] border px-5 py-4">
                        <div className="flex flex-wrap items-start justify-between gap-3">
                            <div>
                                <div className="mb-2 h-1 w-8 rounded-full bg-[#3B1B88]" />
                                <h3 className="adm-title text-[17px] font-bold">Subscription Revenue</h3>
                                <p className="adm-muted mt-1 text-xs">Approved plan activations and renewals this month.</p>
                            </div>
                            <button
                                type="button"
                                className="adm-outline inline-flex items-center gap-2 rounded-[8px] border px-3 py-2 text-xs font-semibold transition hover:bg-[#FCFBFE]"
                            >
                                This month
                                <ChevronDown size={14} />
                            </button>
                        </div>

                        <div className="mt-4 flex flex-wrap items-end justify-between gap-3">
                            <div>
                                <p className="adm-title text-[26px] font-bold tracking-[-0.03em]">₱10,986</p>
                                <p className="adm-success mt-1 inline-flex items-center gap-1 text-xs font-semibold">
                                    <ArrowUpRight size={14} />
                                    12.4% from last month
                                </p>
                            </div>
                            <p className="adm-muted text-xs">June 1 - June 26, 2026</p>
                        </div>

                        <div className="adm-revenue-chart adm-soft-surface mt-4 rounded-xl border border-[#F0ECF5] px-3 pt-2.5">
                            <svg
                                viewBox="0 0 760 222"
                                preserveAspectRatio="none"
                                role="img"
                                aria-label="Subscription revenue trend for June 2026"
                                className="w-full overflow-visible"
                            >
                                <defs>
                                    <linearGradient id="compactRevenueArea" x1="0" x2="0" y1="0" y2="1">
                                        <stop offset="0%" stopColor="#3B1B88" stopOpacity="0.18" />
                                        <stop offset="100%" stopColor="#3B1B88" stopOpacity="0" />
                                    </linearGradient>
                                </defs>
                                {[52, 102, 152, 198].map((y) => (
                                    <line
                                        key={y}
                                        x1="18"
                                        x2="744"
                                        y1={y}
                                        y2={y}
                                        stroke="#EDE7F3"
                                        strokeWidth="1"
                                    />
                                ))}
                                <path d={chart.areaPath} fill="url(#compactRevenueArea)" />
                                <polyline
                                    points={chart.linePath}
                                    fill="none"
                                    stroke="#3B1B88"
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    strokeWidth="3"
                                />
                                {chart.points.filter((_, index) => index % 4 === 0).map((point, index) => (
                                    <circle
                                        key={index}
                                        cx={point.x}
                                        cy={point.y}
                                        r="3"
                                        fill="#FFFFFF"
                                        stroke="#3B1B88"
                                        strokeWidth="2"
                                    />
                                ))}
                            </svg>
                        </div>
                        <div className="adm-muted mt-2 flex justify-between px-1 text-[10px] font-medium">
                            <span>Jun 1</span><span>Jun 7</span><span>Jun 14</span><span>Jun 20</span><span>Jun 26</span>
                        </div>
                    </article>

                    <div className="adm-right-stack">
                        <article className="adm-card adm-plan-mix-card rounded-[16px] border px-5 py-4">
                            <div className="flex items-start justify-between gap-3">
                                <div>
                                    <div className="mb-2 h-1 w-8 rounded-full bg-[#C9951A]" />
                                    <h3 className="adm-title text-[17px] font-bold">Subscriptions by Plan</h3>
                                    <p className="adm-muted mt-1 text-xs">18 stores currently have active access.</p>
                                </div>
                                <span className="adm-secondary rounded-lg border px-2.5 py-1 text-xs font-bold">18 active</span>
                            </div>

                            <div className="mt-5 flex flex-col items-center gap-4 sm:flex-row sm:justify-start sm:gap-5">
                                <div className="adm-donut shrink-0" aria-label="18 active subscriptions: 4 Starter, 5 Business, 9 Enterprise">
                                    <div className="adm-donut-center">
                                        <div>
                                            <p className="adm-title text-2xl font-bold leading-none">18</p>
                                            <p className="adm-muted mt-1 text-[10px] font-semibold uppercase tracking-wide">Total</p>
                                        </div>
                                    </div>
                                </div>

                                <div className="w-full max-w-[188px] space-y-2">
                                    <div className="flex items-center justify-between gap-3 text-xs">
                                        <span className="flex items-center gap-2 font-semibold"><span className="adm-plan-dot adm-plan-dot-starter" />Starter</span>
                                        <span className="adm-title font-bold">4 <span className="adm-muted font-medium">(22%)</span></span>
                                    </div>
                                    <div className="flex items-center justify-between gap-3 text-xs">
                                        <span className="flex items-center gap-2 font-semibold"><span className="adm-plan-dot adm-plan-dot-business" />Business</span>
                                        <span className="adm-title font-bold">5 <span className="adm-muted font-medium">(28%)</span></span>
                                    </div>
                                    <div className="flex items-center justify-between gap-3 text-xs">
                                        <span className="flex items-center gap-2 font-semibold"><span className="adm-plan-dot adm-plan-dot-enterprise" />Enterprise</span>
                                        <span className="adm-title font-bold">9 <span className="adm-muted font-medium">(50%)</span></span>
                                    </div>
                                </div>
                            </div>
                        </article>

                        <article className="adm-card adm-qr-card rounded-[16px] border px-5 py-4">
                            <div className="flex items-start justify-between gap-3">
                                <div>
                                    <div className="mb-2 h-1 w-8 rounded-full bg-[#3B1B88]" />
                                    <h3 className="adm-title text-[17px] font-bold">QR Payment</h3>
                                    <p className="adm-muted mt-1 text-xs">Use this GCash QR for subscription payments.</p>
                                </div>
                                <div className="adm-qr-actions">
                                    <span className="adm-qr-badge"><QrCode size={14} /> GCash</span>
                                    <button
                                        type="button"
                                        onClick={openGcashSettings}
                                        className="adm-qr-edit"
                                    >
                                        <Pencil size={13} />
                                        Edit
                                    </button>
                                </div>
                            </div>

                            <div className="mt-4 flex items-center gap-4">
                                <div className="adm-qr-box shrink-0">
                                    <img
                                        src={gcashSettings.qrImage}
                                        alt="GCash payment QR"
                                        className="adm-qr-image"
                                    />
                                </div>

                                <div className="min-w-0 flex-1">
                                    <p className="adm-title text-sm font-semibold">StockNBook Subscription Payment</p>
                                    <p className="adm-muted mt-1 text-xs">Scan the code and upload the proof of payment after sending your subscription fee.</p>

                                    <div className="mt-3 space-y-2 text-xs">
                                        <div className="flex items-center justify-between gap-3">
                                            <span className="adm-muted">Account</span>
                                            <span className="adm-title text-right font-semibold">{gcashSettings.accountName}</span>
                                        </div>
                                        <div className="flex items-center justify-between gap-3">
                                            <span className="adm-muted">GCash Number</span>
                                            <span className="adm-title text-right font-semibold">{gcashSettings.gcashNumber}</span>
                                        </div>
                                        <div className="flex items-center justify-between gap-3">
                                            <span className="adm-muted">Instruction</span>
                                            <span className="adm-title text-right font-semibold">{gcashSettings.instruction}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </article>
                    </div>
                </section>
            </section>

            {isGcashSettingsOpen && (
                <div className="adm-gcash-settings-layer fixed inset-0 flex items-center justify-center">
                    <button
                        type="button"
                        aria-label="Close payment settings"
                        onClick={closeGcashSettings}
                        className="adm-gcash-settings-backdrop absolute inset-0"
                    />

                    <section
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="gcash-settings-heading"
                        className="adm-gcash-settings-dialog"
                    >
                        <div className="adm-gcash-settings-header">
                            <div>
                                <p className="adm-label text-[10px] font-bold uppercase tracking-[0.12em]">Payment settings</p>
                                <h3 id="gcash-settings-heading" className="adm-title mt-1 text-lg font-bold">Edit GCash Payment Details</h3>
                                <p className="adm-muted mt-1 text-xs">Update the payment QR, GCash account name, number, and owner instruction.</p>
                            </div>
                            <button
                                type="button"
                                onClick={closeGcashSettings}
                                aria-label="Close settings"
                                className="adm-outline grid h-9 w-9 place-items-center rounded-[9px] border"
                            >
                                <X size={18} />
                            </button>
                        </div>

                        <div className="adm-gcash-settings-body">
                            <div className="adm-gcash-preview">
                                <img
                                    src={gcashSettingsForm.qrImage}
                                    alt="GCash QR preview"
                                    className="adm-gcash-preview-image"
                                />
                                <label className="adm-gcash-upload">
                                    <Upload size={13} />
                                    Replace QR
                                    <input
                                        type="file"
                                        accept="image/png,image/jpeg,image/webp"
                                        onChange={handleGcashQrUpload}
                                        className="hidden"
                                    />
                                </label>
                                <p className="adm-muted text-center text-[10px]">PNG, JPG, or WEBP</p>
                            </div>

                            <div className="adm-gcash-settings-form">
                                <label>
                                    GCash Account Name
                                    <input
                                        value={gcashSettingsForm.accountName}
                                        onChange={(event) =>
                                            setGcashSettingsForm((currentSettings) => ({
                                                ...currentSettings,
                                                accountName: event.target.value,
                                            }))
                                        }
                                        placeholder="Account name"
                                    />
                                </label>

                                <label>
                                    GCash Number
                                    <input
                                        value={gcashSettingsForm.gcashNumber}
                                        onChange={(event) =>
                                            setGcashSettingsForm((currentSettings) => ({
                                                ...currentSettings,
                                                gcashNumber: event.target.value,
                                            }))
                                        }
                                        inputMode="numeric"
                                        placeholder="09XX XXX XXXX"
                                    />
                                </label>

                                <label>
                                    Payment Instruction
                                    <input
                                        value={gcashSettingsForm.instruction}
                                        onChange={(event) =>
                                            setGcashSettingsForm((currentSettings) => ({
                                                ...currentSettings,
                                                instruction: event.target.value,
                                            }))
                                        }
                                        placeholder="Instruction for store owners"
                                    />
                                </label>
                            </div>
                        </div>

                        <div className="adm-gcash-settings-footer">
                            <button
                                type="button"
                                onClick={closeGcashSettings}
                                className="adm-outline rounded-[9px] border px-4 py-2 text-xs font-bold"
                            >
                                Cancel
                            </button>
                            <button
                                type="button"
                                onClick={saveGcashSettings}
                                className="adm-primary inline-flex items-center gap-2 rounded-[9px] px-4 py-2 text-xs font-bold"
                            >
                                Save Payment Details
                            </button>
                        </div>
                    </section>
                </div>
            )}

            {selectedPayment && (
                <div className="adm-review-layer fixed inset-0 flex items-center justify-center">
                    <button
                        type="button"
                        aria-label="Close payment review"
                        onClick={closePaymentReview}
                        className="adm-review-backdrop absolute inset-0"
                    />

                    <section
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="payment-review-heading"
                        className="adm-review-dialog relative"
                    >
                        <div className="adm-review-header flex items-start justify-between gap-4">
                            <div>
                                <p className="adm-label text-[10px] font-bold uppercase tracking-[0.12em]">
                                    Payment verification
                                </p>
                                <h3 id="payment-review-heading" className="adm-title mt-1 text-[19px] font-bold">
                                    Review Subscription Payment
                                </h3>
                                <p className="adm-muted mt-1 text-[11px]">
                                    Check the payment details and GCash proof before updating the subscription.
                                </p>
                            </div>
                            <button
                                type="button"
                                aria-label="Close"
                                onClick={closePaymentReview}
                                className="adm-outline grid h-8 w-8 shrink-0 place-items-center rounded-lg border transition hover:bg-[#FCFBFE]"
                            >
                                <X size={17} />
                            </button>
                        </div>

                        <div className="adm-review-body">
                            <div className="space-y-3">
                                <div className="adm-review-card">
                                    <div className="flex items-center gap-3">
                                        <span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-[#F0EAFE] text-[#3B1B88]">
                                            <Store size={18} />
                                        </span>
                                        <div className="min-w-0">
                                            <p className="adm-title truncate text-[13px] font-bold">
                                                {selectedPayment.storeName}
                                            </p>
                                            <p className="adm-muted mt-0.5 truncate text-[10px]">
                                                {selectedPayment.ownerName} · {selectedPayment.ownerEmail}
                                            </p>
                                        </div>
                                    </div>

                                    <dl className="mt-3 grid grid-cols-2 gap-x-5 gap-y-3 border-t border-slate-100 pt-3 text-xs">
                                        <div>
                                            <dt className="adm-muted text-[10px]">Business ID</dt>
                                            <dd className="adm-title mt-1 font-semibold">{selectedPayment.businessId}</dd>
                                        </div>
                                        <div>
                                            <dt className="adm-muted text-[10px]">Current Plan</dt>
                                            <dd className="mt-1"><PlanBadge plan={selectedPayment.currentPlan} /></dd>
                                        </div>
                                        <div>
                                            <dt className="adm-muted text-[10px]">Requested Plan</dt>
                                            <dd className="mt-1"><PlanBadge plan={selectedPayment.requestedPlan} /></dd>
                                        </div>
                                        <div>
                                            <dt className="adm-muted text-[10px]">Billing Period</dt>
                                            <dd className="adm-title mt-1 font-semibold">Monthly</dd>
                                        </div>
                                    </dl>
                                </div>

                                <div className="adm-review-card">
                                    <div className="flex items-center gap-2">
                                        <ReceiptText size={16} className="adm-accent" />
                                        <h4 className="adm-title text-[13px] font-bold">Payment Information</h4>
                                    </div>
                                    <dl className="mt-3 space-y-2.5 text-xs">
                                        <div className="flex items-center justify-between gap-4">
                                            <dt className="adm-muted">Required amount</dt>
                                            <dd className="adm-title font-bold">{currency.format(selectedPayment.amount)}</dd>
                                        </div>
                                        <div className="flex items-center justify-between gap-4">
                                            <dt className="adm-muted">Amount submitted</dt>
                                            <dd className="adm-success font-bold">{currency.format(selectedPayment.amount)}</dd>
                                        </div>
                                        <div className="flex items-center justify-between gap-4">
                                            <dt className="adm-muted">Reference number</dt>
                                            <dd className="adm-title font-mono text-[10px] font-semibold">{selectedPayment.referenceNumber}</dd>
                                        </div>
                                        <div className="flex items-center justify-between gap-4">
                                            <dt className="adm-muted">Payment date</dt>
                                            <dd className="adm-title font-semibold">{selectedPayment.paymentDate}</dd>
                                        </div>
                                        <div className="flex items-center justify-between gap-4">
                                            <dt className="adm-muted">Submitted</dt>
                                            <dd className="adm-title text-right font-semibold">{selectedPayment.submittedAt}</dd>
                                        </div>
                                    </dl>
                                </div>
                            </div>

                            <div className="space-y-3">
                                <div className="adm-review-card">
                                    <div className="flex items-start justify-between gap-3">
                                        <div>
                                            <h4 className="adm-title text-[13px] font-bold">Proof of Payment</h4>
                                            <p className="adm-muted mt-1 text-[10px]">View only — submitted details cannot be edited.</p>
                                        </div>
                                        <FileImage size={18} className="adm-accent shrink-0" />
                                    </div>

                                    <div className="adm-review-proof mt-3">
                                        <div>
                                            <span className="mx-auto grid h-10 w-10 place-items-center rounded-xl bg-white text-[#3B1B88] shadow-sm">
                                                <FileImage size={20} />
                                            </span>
                                            <p className="adm-title mt-2.5 text-[12px] font-bold">{selectedPayment.proofFileName}</p>
                                            <p className="adm-muted mt-1 text-[10px]">Uploaded GCash payment screenshot</p>
                                            <button
                                                type="button"
                                                className="adm-secondary mt-3 inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-[10px] font-bold transition hover:bg-[#EAE2FA]"
                                            >
                                                <Eye size={13} />
                                                View larger proof
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <div className="adm-review-warning">
                                    <div className="flex gap-2.5">
                                        <ShieldAlert size={17} className="adm-warning mt-0.5 shrink-0" />
                                        <div>
                                            <p className="adm-warning text-[11px] font-bold">Manual verification required</p>
                                            <p className="adm-warning mt-1 text-[10px] leading-4">
                                                Compare the amount, reference number, and date with the actual receiving GCash record.
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {reviewAction === null && (
                            <div className="adm-review-actions flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                                <button
                                    type="button"
                                    onClick={() => setReviewAction("reject")}
                                    className="inline-flex items-center justify-center gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3.5 py-2 text-xs font-bold text-rose-700 transition hover:bg-rose-100"
                                >
                                    <XCircle size={15} />
                                    Reject Payment
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setReviewAction("approve")}
                                    className="inline-flex items-center justify-center gap-2 rounded-lg bg-emerald-600 px-3.5 py-2 text-xs font-bold text-white shadow-sm transition hover:bg-emerald-700"
                                >
                                    <CheckCircle2 size={15} />
                                    Approve Payment
                                </button>
                            </div>
                        )}

                        {reviewAction === "approve" && (
                            <div className="adm-review-actions bg-emerald-50/70">
                                <div className="flex gap-2.5">
                                    <CheckCircle2 className="mt-0.5 shrink-0 text-emerald-600" size={18} />
                                    <div>
                                        <h4 className="text-[13px] font-bold text-emerald-950">Approve Subscription Payment?</h4>
                                        <p className="mt-1 text-[11px] leading-5 text-emerald-800">
                                            The {selectedPayment.requestedPlan} Plan will become active for {selectedPayment.storeName} for a new one-month period.
                                        </p>
                                    </div>
                                </div>
                                <div className="mt-3 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                                    <button type="button" onClick={() => setReviewAction(null)} className="adm-outline rounded-lg border px-3.5 py-2 text-xs font-bold transition hover:bg-[#FCFBFE]">Cancel</button>
                                    <button type="button" onClick={confirmApproval} className="rounded-lg bg-emerald-600 px-3.5 py-2 text-xs font-bold text-white shadow-sm transition hover:bg-emerald-700">Confirm Approval</button>
                                </div>
                            </div>
                        )}

                        {reviewAction === "reject" && (
                            <div className="adm-review-actions bg-rose-50/60">
                                <div className="flex gap-2.5">
                                    <XCircle className="mt-0.5 shrink-0 text-rose-600" size={18} />
                                    <div>
                                        <h4 className="text-[13px] font-bold text-rose-950">Reject Subscription Payment</h4>
                                        <p className="mt-1 text-[11px] leading-5 text-rose-800">Choose a reason before rejecting this payment request.</p>
                                    </div>
                                </div>

                                <div className="mt-3 grid gap-3 sm:grid-cols-2">
                                    <label className="block">
                                        <span className="text-[10px] font-bold text-slate-700">Reason for rejection</span>
                                        <select
                                            value={rejectionReason}
                                            onChange={(event) => setRejectionReason(event.target.value)}
                                            className="mt-1 h-9 w-full rounded-lg border border-slate-200 bg-white px-2.5 text-[11px] text-slate-700 outline-none focus:border-rose-300 focus:ring-4 focus:ring-rose-100"
                                        >
                                            <option value="">Select a reason</option>
                                            <option value="Payment not found">Payment not found</option>
                                            <option value="Incorrect amount">Incorrect amount</option>
                                            <option value="Invalid reference number">Invalid reference number</option>
                                            <option value="Duplicate reference number">Duplicate reference number</option>
                                            <option value="Unclear payment proof">Unclear payment proof</option>
                                            <option value="Payment details do not match">Payment details do not match</option>
                                            <option value="Other">Other</option>
                                        </select>
                                    </label>
                                    <label className="block">
                                        <span className="text-[10px] font-bold text-slate-700">Additional explanation</span>
                                        <input
                                            value={rejectionNote}
                                            onChange={(event) => setRejectionNote(event.target.value)}
                                            placeholder="Optional note"
                                            className="mt-1 h-9 w-full rounded-lg border border-slate-200 bg-white px-2.5 text-[11px] text-slate-700 outline-none placeholder:text-slate-400 focus:border-rose-300 focus:ring-4 focus:ring-rose-100"
                                        />
                                    </label>
                                </div>

                                <div className="mt-3 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                                    <button type="button" onClick={() => setReviewAction(null)} className="adm-outline rounded-lg border px-3.5 py-2 text-xs font-bold transition hover:bg-[#FCFBFE]">Cancel</button>
                                    <button type="button" disabled={!rejectionReason} onClick={confirmRejection} className="rounded-lg bg-rose-600 px-3.5 py-2 text-xs font-bold text-white shadow-sm transition hover:bg-rose-700 disabled:cursor-not-allowed disabled:opacity-50">Confirm Rejection</button>
                                </div>
                            </div>
                        )}
                    </section>
                </div>
            )}

        </div>
    );
}
