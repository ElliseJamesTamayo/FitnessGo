"use client";

import { useInventoryController } from "@/hooks/useInventory";
import {
    BranchInventoryView,
    InventoryDialogs,
    PageHeader,
    SearchAndActions,
} from "./_shared";

export default function StaffInventory() {
    const inv = useInventoryController();

    return (
        <>
            <PageHeader
                title="Inventory"
                badge={inv.assignedBranchName || "Assigned Branch"}
                role={inv.role}
                onRefresh={() => void inv.refreshAll()}
            />

            <section className="px-5 py-5">
                <SearchAndActions
                    search={inv.search}
                    setSearch={inv.setSearch}
                    isOwner={false}
                    onManageCategories={inv.openManageCategories}
                    onAddProduct={inv.openAddProduct}
                />

                <BranchInventoryView inv={inv} title="Products" />
            </section>

            <InventoryDialogs inv={inv} />
        </>
    );
}
