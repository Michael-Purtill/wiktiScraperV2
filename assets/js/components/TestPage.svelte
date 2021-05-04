<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langInfo = [];

    onMount(async () => {
        fetch("/api/wordInfo/" + "Czech/pes").then((r) => {return r.json()}).then((d) => {langInfo = d })
    })

</script>

<div>
    {#each langInfo as datum}
        <div>
            <h3>{datum.title.replace("[ edit ]", "").replace("[edit]", "")}</h3>
            {#each datum.content as content}
                {#if content.tag == "p"}
                <p>{content.innerContent.replace("\n", "")}</p>
                {:else if content.tag == "ul" || content.tag == "ol"}
                {#each content.innerContent as innerContent}
                    <li>{innerContent.replace("\n", "")}</li>
                {/each}

                {:else if content.tag="table"}
                <table>
                    <tbody>
                        {#each content.innerContent as innerContent}
                            <tr>
                                {#each innerContent as inner}
                                    <td>{inner.replace("\n", "")}</td>
                                {/each}
                            </tr>
                        {/each}
                    </tbody>
                </table>
                {/if}
            {/each}
        </div>
    {/each}
</div>

<style></style>