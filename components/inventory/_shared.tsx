/* eslint-disable @typescript-eslint/no-explicit-any */

import type * as React from "react";
import {
    AlertTriangle,
    ArchiveX,
    Boxes,
    RefreshCw,
    Search,
    Store,
} from "lucide-react";
import type { InventoryController } from "@/hooks/useInventory";

export type InventoryRole = "owner" | "manager" | "staff" | "";

export type ProductVariant = {
    id: number;
    productId: number;
    variantValues: Record<string, string>;
    stock: number;
    alertLevel: number;
    originalPrice: number;
    salesPrice: number;
    createdAt?: string;
};

export type ProductVariantSave = {
    id?: number;
    variantValues: Record<string, string>;
    stock: number;
    alertLevel: number;
    originalPrice: number;
    salesPrice: number;
};

export type Product = {
    id: number;
    storeId?: number | null;
    branchId?: number | null;
    branchName?: string | null;
    name: string;
    category: string;
    stock: number;
    alertLevel: number;
    originalPrice: number;
    salesPrice: number;
    createdAt?: string;
    hasVariants: boolean;
    variants?: ProductVariant[];
};

export type ProductSaveData = {
    storeId?: number | null;
    branchId?: number | null;
    branchName?: string | null;
    name: string;
    category: string;
    stock: number;
    alertLevel: number;
    originalPrice: number;
    salesPrice: number;
    hasVariants: boolean;
    variants?: ProductVariantSave[];
};

export type Category = {
    id: number;
    categoryName: string;
    description?: string;
};

export type Branch = {
    id: number;
    branchName: string;
};

export type ApiError = {
    error?: string;
};

export type PendingProductSave =
    | {
    mode: "add";
    data: ProductSaveData;
}
    | {
    mode: "edit";
    editingId: number;
    before: Product;
    after: ProductSaveData;
};

const STATUS_STYLE = {
    in: "bg-[#E6F6EA] text-[#226B36]",
    low: "bg-[#FFF4D8] text-[#8A5A00]",
    out: "bg-[#FFE5E5] text-[#9A2424]",
};

export const labelClass = "text-xs font-semibold text-[#5A476A]";

export const fieldClass =
    "w-full rounded-xl border border-[#E3D8EA] bg-white p-3 text-sm text-[#1A1220] placeholder:text-[#9B8AAA] focus:border-[#2B174C] focus:outline-none focus:ring-1 focus:ring-[#2B174C]";

export function money(n: number) {
    const value = Number(n ?? 0);
    return `₱${Number.isFinite(value) ? value.toFixed(2) : "0.00"}`;
}

export function normalizeCat(s: string) {
    return s.trim();
}

export function getApiErrorMessage(data: unknown, fallback: string): string {
    if (typeof data === "object" && data !== null && "error" in data) {
        const err = (data as ApiError).error;
        if (typeof err === "string" && err.trim().length > 0) {
            return err;
        }
    }

    return fallback;
}

export function getTokenOrAlert(): string | null {
    const token = sessionStorage.getItem("token");

    if (!token) {
        alert("❌ Missing login token. Please login again.");
        return null;
    }

    return token;
}

export async function safeParseResponse<T = unknown>(
    res: Response
): Promise<{ data: T; text: string }> {
    const text = await res.text();

    try {
        return { data: JSON.parse(text) as T, text };
    } catch {
        return { data: { error: text || "Non-JSON response from server" } as T, text };
    }
}

export function normalizeProductVariant(raw: any): ProductVariant {
    const rawValues = raw.variantValues ?? raw.variant_values ?? {};
    let parsedVariantValues: Record<string, string> = {};

    try {
        parsedVariantValues = typeof rawValues === "string" ? JSON.parse(rawValues) : rawValues ?? {};
    } catch {
        parsedVariantValues = {};
    }

    return {
        id: Number(raw.id),
        productId: Number(raw.productId ?? raw.product_id),
        variantValues: parsedVariantValues,
        stock: Number(raw.stock ?? 0),
        alertLevel: Number(raw.alertLevel ?? raw.alert_level ?? 0),
        originalPrice: Number(raw.originalPrice ?? raw.original_price ?? 0),
        salesPrice: Number(raw.salesPrice ?? raw.sales_price ?? 0),
        createdAt: raw.createdAt ?? raw.created_at ?? "",
    };
}

export function normalizeProduct(raw: any): Product {
    return {
        id: Number(raw.id),
        storeId: raw.storeId ?? raw.store_id ?? null,
        branchId: raw.branchId ?? raw.branch_id ?? null,
        branchName: raw.branchName ?? raw.branch_name ?? null,
        name: raw.name || "",
        category: raw.category || "",
        stock: Number(raw.stock ?? 0),
        alertLevel: Number(raw.alertLevel ?? raw.alert_level ?? 0),
        originalPrice: Number(raw.originalPrice ?? raw.original_price ?? 0),
        salesPrice: Number(raw.salesPrice ?? raw.sales_price ?? 0),
        createdAt: raw.createdAt ?? raw.created_at ?? "",
        hasVariants: Boolean(raw.hasVariants ?? raw.has_variants ?? false),
        variants: Array.isArray(raw.variants) ? raw.variants.map(normalizeProductVariant) : [],
    };
}

export function getStatus(p: Product) {
    if (p.stock <= 0) return { label: "Out of Stock", style: STATUS_STYLE.out };
    if (p.stock <= p.alertLevel) return { label: "Low Stock", style: STATUS_STYLE.low };
    return { label: "In Stock", style: STATUS_STYLE.in };
}

export function pillClass(isSelected: boolean) {
    return [
        "rounded-full px-4 py-1.5 text-xs transition",
        isSelected
            ? "bg-[#2B174C] text-white font-bold shadow-sm"
            : "border border-[#E6DDF0] bg-white text-[#6A5D6F] font-medium hover:bg-[#F7F1FF]",
    ].join(" ");
}

export function StoreIcon() {
    return <Store size={17} className="text-[#5F4E75]" />;
}

export function PageHeader({
                               title,
                               badge,
                               role,
                               onRefresh,
                           }: {
    title: string;
    badge: string;
    role: InventoryRole;
    onRefresh: () => void;
}) {
    const currentMonth = new Date().toLocaleDateString("en-PH", {
        month: "long",
        year: "numeric",
    });

    return (
        <div className="sticky top-0 z-20 border-b border-[#E9E0EF] bg-[#FFFDF8]/95 backdrop-blur">
            <div className="flex items-center justify-between px-5 py-3">
                <div className="flex flex-wrap items-center gap-2">
                    <h1 className="font-serif text-[22px] font-semibold text-[#1A1220]">{title}</h1>
                    <span className="rounded-md bg-[#EFE8F8] px-3 py-1 text-xs font-medium text-[#4E2C66]">
            {badge}
          </span>
                </div>

                <div className="flex items-center gap-2">
                    <div className="rounded-lg border border-[#E6DDF0] bg-white px-4 py-2 text-xs text-[#6A5D6F] shadow-sm">
                        {currentMonth}
                    </div>

                    <button
                        onClick={onRefresh}
                        className="flex h-9 w-9 items-center justify-center rounded-lg border border-[#E6DDF0] bg-white text-[#5F4E75] shadow-sm hover:bg-[#F7F1FF]"
                        title="Refresh"
                    >
                        <RefreshCw size={15} />
                    </button>

                    <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#2B174C] text-xs font-semibold text-white shadow-sm">
                        {role === "owner" ? "OW" : role === "staff" ? "ST" : "MG"}
                    </div>
                </div>
            </div>
        </div>
    );
}

export function SearchAndActions({
                                     search,
                                     setSearch,
                                     isOwner,
                                     onManageCategories,
                                     onAddProduct,
                                 }: {
    search: string;
    setSearch: (value: string) => void;
    isOwner: boolean;
    onManageCategories: () => void;
    onAddProduct: () => void;
}) {
    return (
        <div className="mb-4 flex flex-col gap-3 lg:flex-row lg:items-center">
            <div className="relative flex-1">
                <Search size={15} className="absolute left-4 top-1/2 -translate-y-1/2 text-[#9B8AAA]" />
                <input
                    placeholder={isOwner ? "Search product or category in selected branch..." : "Search products..."}
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full rounded-xl border border-[#E3D8EA] bg-white px-4 py-3 pl-10 text-sm text-[#1A1220] outline-none shadow-sm placeholder:text-[#9B8AAA] focus:border-[#2B174C]"
                />
            </div>

            <button
                onClick={onManageCategories}
                className="rounded-xl border border-[#E6DDF0] bg-white px-5 py-3 text-sm font-semibold text-[#2B174C] shadow-sm hover:bg-[#F7F1FF]"
            >
                Manage Categories
            </button>

            <button
                onClick={onAddProduct}
                className="rounded-xl bg-[#2B174C] px-5 py-3 text-sm font-semibold text-white shadow-sm hover:bg-[#1B0D31]"
            >
                + Add Product
            </button>
        </div>
    );
}

export function StatCard({
                             icon,
                             label,
                             value,
                         }: {
    icon: React.ReactNode;
    label: string;
    value: string | number;
}) {
    return (
        <div className="rounded-[16px] border border-[#E6DDF0] bg-white p-4 shadow-sm">
            <div className="flex items-center gap-2 text-[#5F4E75]">
                {icon}
                <p className="text-xs font-semibold uppercase tracking-[0.12em]">{label}</p>
            </div>
            <p className="mt-2 font-serif text-2xl font-semibold text-[#1A1220]">{value}</p>
        </div>
    );
}

export function InventoryStats({
                                   products,
                               }: {
    products: Product[];
}) {
    const totalProducts = products.length;
    const lowStock = products.filter((p) => p.stock > 0 && p.stock <= p.alertLevel).length;
    const outStock = products.filter((p) => p.stock <= 0).length;
    const value = products.reduce((sum, p) => sum + p.salesPrice * p.stock, 0);

    return (
        <div className="grid gap-3 md:grid-cols-4">
            <StatCard icon={<Boxes size={16} />} label="Items" value={totalProducts} />
            <StatCard icon={<AlertTriangle size={16} />} label="Low Stock" value={lowStock} />
            <StatCard icon={<ArchiveX size={16} />} label="Out of Stock" value={outStock} />
            <StatCard icon={<Boxes size={16} />} label="Value" value={money(value)} />
        </div>
    );
}

export function BranchListItem({
                                   branch,
                                   products,
                                   selected,
                                   onClick,
                               }: {
    branch: Branch;
    products: Product[];
    selected: boolean;
    onClick: () => void;
}) {
    const low = products.filter((p) => p.stock > 0 && p.stock <= p.alertLevel).length;
    const out = products.filter((p) => p.stock <= 0).length;

    return (
        <button
            type="button"
            onClick={onClick}
            className={`w-full rounded-2xl border px-4 py-3 text-left transition ${
                selected ? "border-[#2B174C] bg-[#F7F1FF] shadow-sm" : "border-[#E6DDF0] bg-white hover:bg-[#FFFCF7]"
            }`}
        >
            <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                    <p className="truncate font-serif text-base font-semibold text-[#1A1220]">{branch.branchName}</p>
                    <p className="mt-1 text-xs text-[#8A7A91]">
                        {products.length} product{products.length !== 1 ? "s" : ""}
                    </p>
                </div>
                <div className="rounded-full bg-[#FFFDF8] px-2 py-1 text-[10px] font-semibold text-[#5F4E75]">
                    {products.length}
                </div>
            </div>

            <div className="mt-3 flex gap-2 text-[10px]">
                <span className="rounded-full bg-[#FFFDF8] px-2 py-1 text-[#8A5A00]">Low {low}</span>
                <span className="rounded-full bg-[#FFFDF8] px-2 py-1 text-[#9A2424]">Out {out}</span>
            </div>
        </button>
    );
}

export function CategoryPills({
                                  categories,
                                  selectedCategory,
                                  setSelectedCategory,
                              }: {
    categories: string[];
    selectedCategory: string;
    setSelectedCategory: (value: string) => void;
}) {
    return (
        <section className="rounded-[16px] border border-[#E6DDF0] bg-white p-4 shadow-sm">
            <div className="mb-3 flex items-center justify-between">
                <h2 className="text-sm font-semibold text-[#1A1220]">Categories</h2>
                <span className="text-xs text-[#9B8AAA]">{categories.length} total</span>
            </div>

            <div className="flex flex-wrap gap-2">
                <button type="button" onClick={() => setSelectedCategory("All")} className={pillClass(selectedCategory === "All")}>
                    All
                </button>

                {categories.map((c) => (
                    <button key={c} type="button" onClick={() => setSelectedCategory(c)} className={pillClass(selectedCategory === c)}>
                        {c}
                    </button>
                ))}
            </div>
        </section>
    );
}

export function EmptyInventory({ message }: { message: string }) {
    return (
        <div className="flex min-h-[220px] items-center justify-center rounded-xl border border-dashed border-[#E6DDF0] bg-[#FFFCF7]">
            <p className="text-sm text-[#9B8AAA]">{message}</p>
        </div>
    );
}

export function ProductTable({
                                 products,
                                 isOwner,
                                 onEdit,
                                 onDelete,
                             }: {
    products: Product[];
    isOwner: boolean;
    onEdit: (p: Product) => void;
    onDelete: (p: Product) => void;
}) {
    return (
        <div className="w-full overflow-x-auto">
            <table className={`w-full ${isOwner ? "min-w-[860px]" : "min-w-[780px]"} text-xs sm:text-sm`}>
                <thead>
                <tr className="border-b border-[#E6DDF0]">
                    {["Product", ...(isOwner ? ["Branch"] : []), "Category", "Variants", "Stock", "Alert", "Original", "Sales", "Status", "Actions"].map(
                        (head) => (
                            <th
                                key={head}
                                className={`${head === "Product" ? "text-left" : "text-center"} pb-3 text-[11px] font-semibold uppercase tracking-[0.12em] text-[#806A8C]`}
                            >
                                {head}
                            </th>
                        )
                    )}
                </tr>
                </thead>

                <tbody>
                {products.map((p) => {
                    const s = getStatus(p);

                    return (
                        <tr key={p.id} className="border-b border-[#EFE7F4] last:border-0">
                            <td className="py-4 pr-3">
                                <p className="font-serif font-semibold text-[#1A1220]">{p.name}</p>
                                {p.hasVariants && p.variants && p.variants.length > 0 && (
                                    <div className="mt-1 flex flex-wrap gap-1">
                                        {p.variants.slice(0, 2).map((variant) => (
                                            <span key={variant.id} className="rounded-full bg-[#F7F1FF] px-2 py-0.5 text-[10px] text-[#4E2C66]">
                          {Object.values(variant.variantValues || {}).join(" / ")}
                        </span>
                                        ))}
                                        {p.variants.length > 2 && (
                                            <span className="rounded-full bg-[#F7F1FF] px-2 py-0.5 text-[10px] text-[#4E2C66]">
                          +{p.variants.length - 2} more
                        </span>
                                        )}
                                    </div>
                                )}
                            </td>

                            {isOwner && <td className="py-4 text-center text-[#6A5D6F]">{p.branchName || "Unassigned"}</td>}
                            <td className="py-4 text-center text-[#6A5D6F]">{p.category}</td>
                            <td className="py-4 text-center text-[#6A5D6F]">{p.hasVariants ? p.variants?.length || 0 : "No"}</td>
                            <td className="py-4 text-center text-[#1A1220]">{p.stock}</td>
                            <td className="py-4 text-center text-[#6A5D6F]">{p.alertLevel}</td>
                            <td className="py-4 text-center text-[#6A5D6F]">{money(p.originalPrice)}</td>
                            <td className="py-4 text-center text-[#1A1220]">{money(p.salesPrice)}</td>
                            <td className="py-4 text-center">
                                <span className={`rounded-full px-2.5 py-1 text-[11px] font-semibold ${s.style}`}>{s.label}</span>
                            </td>
                            <td className="py-4 text-center">
                                <button onClick={() => onEdit(p)} className="mr-3 text-xs font-semibold text-[#2B174C] hover:underline">
                                    Edit
                                </button>
                                <button onClick={() => onDelete(p)} className="text-xs font-semibold text-red-500 hover:underline">
                                    Delete
                                </button>
                            </td>
                        </tr>
                    );
                })}
                </tbody>
            </table>
        </div>
    );
}

export function ProductListSection({
                                       title,
                                       products,
                                       isOwner,
                                       emptyMessage,
                                       onEdit,
                                       onDelete,
                                   }: {
    title: string;
    products: Product[];
    isOwner: boolean;
    emptyMessage: string;
    onEdit: (p: Product) => void;
    onDelete: (p: Product) => void;
}) {
    return (
        <section className="rounded-[16px] border border-[#E6DDF0] bg-white p-4 shadow-sm">
            <div className="mb-4">
                <h2 className="font-serif text-base font-semibold text-[#1A1220]">{title}</h2>
                <p className="text-xs text-[#9B8AAA]">
                    {products.length} item{products.length !== 1 ? "s" : ""}
                </p>
            </div>

            {products.length === 0 ? (
                <EmptyInventory message={emptyMessage} />
            ) : (
                <ProductTable products={products} isOwner={isOwner} onEdit={onEdit} onDelete={onDelete} />
            )}
        </section>
    );
}

export function BranchInventoryView({ inv, title }: { inv: InventoryController; title: string }) {
    return (
        <div className="space-y-4">
            <InventoryStats products={inv.baseProducts} />
            <CategoryPills categories={inv.categories} selectedCategory={inv.selectedCategory} setSelectedCategory={inv.setSelectedCategory} />
            <ProductListSection
                title={title}
                products={inv.filteredProducts}
                isOwner={false}
                emptyMessage="No products found."
                onEdit={inv.handleEditProduct}
                onDelete={inv.requestDeleteProduct}
            />
        </div>
    );
}

export function InventoryDialogs({ inv }: { inv: InventoryController }) {
    const productSaveTitle = inv.pendingProductSave?.mode === "edit" ? "Update Product" : "Add Product";
    const productSaveButton = inv.pendingProductSave?.mode === "edit" ? "Update Product" : "Add Product";

    return (
        <>
            {inv.showForm && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4 backdrop-blur-sm">
                    <div className="max-h-[90vh] w-full max-w-md overflow-y-auto rounded-2xl bg-white p-5 shadow-xl sm:p-6">
                        <div className="mb-4 flex items-center justify-between">
                            <h2 className="font-serif text-lg font-semibold text-[#1A1220]">
                                {inv.formMode === "category" ? "Manage Categories" : inv.editingId ? "Edit Product" : "Add Product"}
                            </h2>
                            <button onClick={() => inv.setShowForm(false)} className="text-[#9B8AAA] hover:text-[#1A1220]">
                                ✕
                            </button>
                        </div>

                        <form
                            onSubmit={(e) => {
                                if (inv.formMode === "product") inv.handleSubmitProduct(e);
                                else e.preventDefault();
                            }}
                            className="space-y-3"
                        >
                            {inv.formMode === "category" ? <CategoryForm inv={inv} /> : <ProductForm inv={inv} />}
                        </form>
                    </div>
                </div>
            )}

            {inv.showConfirmProductSaveDialog && inv.pendingProductSave && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 px-4 backdrop-blur-sm">
                    <div className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white p-5 shadow-xl sm:p-6">
                        <div className="mb-3 flex items-start justify-between gap-4">
                            <div>
                                <h3 className="font-serif text-xl font-semibold text-[#1A1220]">{productSaveTitle}</h3>
                                <p className="mt-1 text-sm text-[#6A5D6F]">Are you sure you want to save this product?</p>
                            </div>
                            <button onClick={inv.closeConfirmProductSaveDialog} className="text-[#9B8AAA] hover:text-[#1A1220]">
                                ✕
                            </button>
                        </div>

                        <div className="mt-4 flex justify-end gap-2">
                            <button
                                type="button"
                                onClick={inv.closeConfirmProductSaveDialog}
                                className="rounded-xl border border-[#E6DDF0] bg-white px-4 py-2 text-sm font-medium text-[#6A5D6F] hover:bg-[#F7F1FF]"
                            >
                                Cancel
                            </button>
                            <button
                                type="button"
                                onClick={inv.confirmSaveProduct}
                                className="rounded-xl bg-[#2B174C] px-4 py-2 text-sm font-semibold text-white hover:bg-[#1B0D31]"
                            >
                                {productSaveButton}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {inv.showDeleteProductDialog && inv.productToDelete && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 px-4 backdrop-blur-sm">
                    <div className="w-full max-w-lg rounded-2xl bg-white p-5 shadow-xl sm:p-6">
                        <h3 className="font-serif text-lg font-semibold text-[#1A1220]">Delete Product</h3>
                        <p className="mt-1 text-sm text-[#6A5D6F]">
                            Are you sure you want to delete <span className="font-semibold">{inv.productToDelete.name}</span>?
                        </p>
                        <div className="mt-4 flex justify-end gap-2">
                            <button
                                type="button"
                                onClick={inv.closeDeleteProductDialog}
                                className="rounded-xl border border-[#E6DDF0] bg-white px-4 py-2 text-sm font-medium text-[#6A5D6F] hover:bg-[#F7F1FF]"
                            >
                                Cancel
                            </button>
                            <button
                                type="button"
                                onClick={inv.confirmDeleteProduct}
                                className="rounded-xl bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700"
                            >
                                Delete Product
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
}

function CategoryForm({ inv }: { inv: InventoryController }) {
    return (
        <>
            <div className="space-y-1">
                <label className={labelClass}>Category Name</label>
                <div className="flex gap-2">
                    <input
                        value={inv.category}
                        onChange={(e) => inv.setCategory(e.target.value)}
                        placeholder="Type to search or add new..."
                        className={fieldClass}
                    />
                    <button
                        type="button"
                        onClick={() => void inv.addCategoryNow(inv.category)}
                        className="rounded-xl bg-[#2B174C] px-4 text-sm font-semibold text-white hover:bg-[#1B0D31]"
                    >
                        Add
                    </button>
                </div>
            </div>

            <div className="space-y-2">
                <p className={labelClass}>Existing Categories</p>
                <div className="max-h-48 space-y-2 overflow-auto">
                    {inv.filteredCategoriesForManage.length === 0 ? (
                        <p className="text-sm text-[#9B8AAA]">No matching categories.</p>
                    ) : (
                        inv.filteredCategoriesForManage.map((c) => <CategoryRow key={c} inv={inv} category={c} />)
                    )}
                </div>
            </div>
        </>
    );
}

function CategoryRow({ inv, category }: { inv: InventoryController; category: string }) {
    const isEditing = inv.editingCategory === category;

    return (
        <div className="flex items-center justify-between rounded-xl bg-[#F8F2EA] p-2 text-[#1A1220]">
            {isEditing ? (
                <input
                    value={inv.editCategoryValue}
                    onChange={(e) => inv.setEditCategoryValue(e.target.value)}
                    className="mr-2 flex-1 rounded-lg border border-[#E3D8EA] px-2 py-1 text-sm text-[#1A1220] focus:border-[#2B174C] focus:outline-none"
                />
            ) : (
                <span className="text-sm font-medium">{category}</span>
            )}

            <div className="flex items-center gap-2">
                {isEditing ? (
                    <>
                        <button
                            type="button"
                            onClick={() => void inv.updateCategoryNow(category, inv.editCategoryValue)}
                            className="text-xs font-semibold text-green-600 hover:underline"
                        >
                            Save
                        </button>
                        <button type="button" onClick={inv.cancelEditCategory} className="text-xs font-semibold text-[#6A5D6F] hover:underline">
                            Cancel
                        </button>
                    </>
                ) : (
                    <>
                        <button type="button" onClick={() => inv.startEditCategory(category)} className="text-xs font-semibold text-[#2B174C] hover:underline">
                            Edit
                        </button>
                        <button
                            type="button"
                            onClick={() => void inv.deleteCategoryNow(category)}
                            className="text-xs font-semibold text-red-500 hover:underline"
                        >
                            Delete
                        </button>
                    </>
                )}
            </div>
        </div>
    );
}

function ProductForm({ inv }: { inv: InventoryController }) {
    return (
        <>
            {inv.isOwner && (
                <div className="space-y-1">
                    <label className={labelClass}>Branch</label>
                    <select value={inv.productBranchId} onChange={(e) => inv.setProductBranchId(e.target.value)} className={fieldClass}>
                        <option value="">Select branch</option>
                        {inv.branches.map((b) => (
                            <option key={b.id} value={b.id}>
                                {b.branchName}
                            </option>
                        ))}
                    </select>
                </div>
            )}

            {inv.isBranchUser && (
                <div className="rounded-xl bg-[#F7F1FF] px-3 py-2 text-xs font-medium text-[#4E2C66]">
                    Branch: {inv.assignedBranchName || "Assigned Branch"}
                </div>
            )}

            <div className="space-y-1">
                <label className={labelClass}>Product Name</label>
                <input value={inv.name} onChange={(e) => inv.setName(e.target.value)} className={fieldClass} />
            </div>

            <div className="space-y-1">
                <label className={labelClass}>Category</label>
                <select value={inv.category} onChange={(e) => inv.setCategory(e.target.value)} className={fieldClass}>
                    <option value="">Select category</option>
                    {inv.categories.map((c) => (
                        <option key={c} value={c}>
                            {c}
                        </option>
                    ))}
                </select>
            </div>

            <label className="flex items-center gap-2 rounded-xl border border-[#E3D8EA] bg-[#FFFCF7] p-3 text-sm font-semibold text-[#2B174C]">
                <input type="checkbox" checked={inv.hasVariants} onChange={(e) => inv.setHasVariants(e.target.checked)} />
                Product has variants
            </label>

            {inv.hasVariants ? <VariantEditor inv={inv} /> : <SimpleProductFields inv={inv} />}

            <button type="submit" className="w-full rounded-xl bg-[#2B174C] py-3 text-sm font-semibold text-white transition hover:bg-[#1B0D31]">
                Save Product
            </button>
        </>
    );
}

function SimpleProductFields({ inv }: { inv: InventoryController }) {
    return (
        <>
            <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1">
                    <label className={labelClass}>Stock</label>
                    <input type="number" value={inv.stock} onChange={(e) => inv.setStock(e.target.value)} className={fieldClass} />
                </div>
                <div className="space-y-1">
                    <label className={labelClass}>Alert Level</label>
                    <input type="number" value={inv.alertLevel} onChange={(e) => inv.setAlertLevel(e.target.value)} className={fieldClass} />
                </div>
            </div>

            <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1">
                    <label className={labelClass}>Original Price</label>
                    <input type="number" value={inv.originalPrice} onChange={(e) => inv.setOriginalPrice(e.target.value)} className={fieldClass} />
                </div>
                <div className="space-y-1">
                    <label className={labelClass}>Sales Price</label>
                    <input type="number" value={inv.salesPrice} onChange={(e) => inv.setSalesPrice(e.target.value)} className={fieldClass} />
                </div>
            </div>
        </>
    );
}

function VariantEditor({ inv }: { inv: InventoryController }) {
    return (
        <div className="space-y-3 rounded-xl border border-[#E6DDF0] bg-[#FFFCF7] p-3">
            <div className="flex items-center justify-between">
                <p className="text-sm font-semibold text-[#1A1220]">Variants</p>
                <button type="button" onClick={inv.addVariantRow} className="rounded-lg bg-[#2B174C] px-3 py-1.5 text-xs font-semibold text-white hover:bg-[#1B0D31]">
                    + Variant
                </button>
            </div>

            {inv.variants.length === 0 ? (
                <p className="text-xs text-[#9B8AAA]">No variants added yet.</p>
            ) : (
                inv.variants.map((variant, index) => (
                    <div key={index} className="space-y-2 rounded-xl bg-white p-3">
                        <div className="flex items-center justify-between">
                            <p className="text-xs font-semibold text-[#5A476A]">Variant {index + 1}</p>
                            <button type="button" onClick={() => inv.removeVariantRow(index)} className="text-xs font-semibold text-red-500 hover:underline">
                                Remove
                            </button>
                        </div>

                        <div className="grid grid-cols-2 gap-2">
                            <input
                                placeholder="Size ex. Small"
                                value={variant.variantValues.size || ""}
                                onChange={(e) => inv.updateVariantValue(index, "size", e.target.value)}
                                className={fieldClass}
                            />
                            <input
                                placeholder="Color ex. Black"
                                value={variant.variantValues.color || ""}
                                onChange={(e) => inv.updateVariantValue(index, "color", e.target.value)}
                                className={fieldClass}
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-2">
                            <input type="number" placeholder="Stock" value={variant.stock} onChange={(e) => inv.updateVariantField(index, "stock", e.target.value)} className={fieldClass} />
                            <input type="number" placeholder="Alert Level" value={variant.alertLevel} onChange={(e) => inv.updateVariantField(index, "alertLevel", e.target.value)} className={fieldClass} />
                        </div>

                        <div className="grid grid-cols-2 gap-2">
                            <input type="number" placeholder="Original Price" value={variant.originalPrice} onChange={(e) => inv.updateVariantField(index, "originalPrice", e.target.value)} className={fieldClass} />
                            <input type="number" placeholder="Sales Price" value={variant.salesPrice} onChange={(e) => inv.updateVariantField(index, "salesPrice", e.target.value)} className={fieldClass} />
                        </div>
                    </div>
                ))
            )}
        </div>
    );
}
