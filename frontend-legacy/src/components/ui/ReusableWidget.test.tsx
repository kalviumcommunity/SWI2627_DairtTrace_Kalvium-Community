import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { ReusableWidget } from "./ReusableWidget";

describe("ReusableWidget", () => {
  it("renders the title, description, and content provided by the consumer", () => {
    render(
      <ReusableWidget
        title="Milk collection summary"
        description="Today’s intake is ready for review."
        actions={<button type="button">Export</button>}
      >
        <p>42.5 litres collected</p>
      </ReusableWidget>,
    );

    expect(screen.getByRole("heading", { name: "Milk collection summary" })).toBeVisible();
    expect(screen.getByText("Today’s intake is ready for review.")).toBeVisible();
    expect(screen.getByText("42.5 litres collected")).toBeVisible();
    expect(screen.getByRole("button", { name: "Export" })).toBeVisible();
  });

  it("supports alternate visual tones without losing the base layout", () => {
    render(
      <ReusableWidget tone="success" className="custom-widget">
        <p>Saved successfully</p>
      </ReusableWidget>,
    );

    const widget = screen.getAllByTestId("reusable-widget").at(-1)!;

    expect(widget).toHaveClass("custom-widget");
    expect(widget).toHaveClass("border-emerald-200");
    expect(screen.getByText("Saved successfully")).toBeVisible();
  });
});
